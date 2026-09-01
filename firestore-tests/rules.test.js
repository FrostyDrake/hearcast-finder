// Security rules tests for HearCast Finder (AC07).
// Run against the local Firestore emulator: `firebase emulators:start --only firestore`
// then, from this folder: `npm install && npm test`.

const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert");

const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");
const {
  doc,
  setDoc,
  updateDoc,
  deleteDoc,
  collection,
  addDoc,
  getDocs,
} = require("firebase/firestore");

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "hearcast-rules-test",
    firestore: {
      rules: fs.readFileSync(
        path.join(__dirname, "..", "firestore.rules"),
        "utf8",
      ),
      host: "localhost",
      port: 8080,
    },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
});

async function seedAdmin(uid) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "users", uid), {
      id: uid,
      email: `${uid}@example.com`,
      role: "admin",
    });
  });
}

async function seedLocation(locationId, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "locations", locationId), data);
  });
}

test("a signed-out user cannot read locations", async () => {
  const db = testEnv.unauthenticatedContext().firestore();
  await assertFails(getDocs(collection(db, "locations")));
});

test("a signed-in user can submit a candidate location", async () => {
  const db = testEnv.authenticatedContext("user-1").firestore();
  await assertSucceeds(
    addDoc(collection(db, "locations"), {
      name: "Test Hall",
      status: "candidate",
      ownerId: "user-1",
    }),
  );
});

test("a signed-in user cannot create a location as already verified", async () => {
  const db = testEnv.authenticatedContext("user-1").firestore();
  await assertFails(
    addDoc(collection(db, "locations"), {
      name: "Test Hall",
      status: "verified",
      ownerId: "user-1",
    }),
  );
});

test("no client — not even an admin — can update or delete a location directly", async () => {
  await seedLocation("loc-1", {name: "Test Hall", status: "candidate"});
  await seedAdmin("admin-1");

  const userDb = testEnv.authenticatedContext("user-1").firestore();
  const adminDb = testEnv.authenticatedContext("admin-1").firestore();

  await assertFails(updateDoc(doc(userDb, "locations", "loc-1"), {status: "verified"}));
  await assertFails(updateDoc(doc(adminDb, "locations", "loc-1"), {status: "verified"}));
  await assertFails(deleteDoc(doc(adminDb, "locations", "loc-1")));
});

test("a user can only create their own profile with role user", async () => {
  const db = testEnv.authenticatedContext("user-1").firestore();

  await assertFails(
    setDoc(doc(db, "users", "user-1"), {id: "user-1", email: "a@b.com", role: "admin"}),
  );
  await assertSucceeds(
    setDoc(doc(db, "users", "user-1"), {id: "user-1", email: "a@b.com", role: "user"}),
  );
  await assertFails(
    setDoc(doc(db, "users", "someone-else"), {id: "someone-else", email: "a@b.com", role: "user"}),
  );
});

test("a user can submit a pending verification request but not a resolved one", async () => {
  const db = testEnv.authenticatedContext("user-1").firestore();

  await assertSucceeds(
    addDoc(collection(db, "verificationRequests"), {
      locationId: "loc-1",
      userId: "user-1",
      status: "pending",
    }),
  );
  await assertFails(
    addDoc(collection(db, "verificationRequests"), {
      locationId: "loc-1",
      userId: "user-1",
      status: "approved",
    }),
  );
});

test("only an admin can approve a verification request", async () => {
  await seedAdmin("admin-1");
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "verificationRequests", "req-1"), {
      locationId: "loc-1",
      userId: "user-1",
      status: "pending",
    });
  });

  const userDb = testEnv.authenticatedContext("user-1").firestore();
  const adminDb = testEnv.authenticatedContext("admin-1").firestore();

  await assertFails(
    updateDoc(doc(userDb, "verificationRequests", "req-1"), {status: "approved"}),
  );
  await assertSucceeds(
    updateDoc(doc(adminDb, "verificationRequests", "req-1"), {status: "approved"}),
  );
});

test("only an admin can read reports", async () => {
  await seedAdmin("admin-1");
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "reports", "report-1"), {userId: "user-1", locationId: "loc-1"});
  });

  const userDb = testEnv.authenticatedContext("user-1").firestore();
  const adminDb = testEnv.authenticatedContext("admin-1").firestore();

  await assertFails(getDocs(collection(userDb, "reports")));
  await assertSucceeds(getDocs(collection(adminDb, "reports")));
});

test("only an admin can add a broadcast profile to a location", async () => {
  await seedLocation("loc-1", {name: "Test Hall", status: "verified"});
  await seedAdmin("admin-1");

  const userDb = testEnv.authenticatedContext("user-1").firestore();
  const adminDb = testEnv.authenticatedContext("admin-1").firestore();

  await assertFails(
    addDoc(collection(userDb, "locations", "loc-1", "broadcasts"), {
      locationId: "loc-1",
      name: "Main Hall Audio",
    }),
  );
  await assertSucceeds(
    addDoc(collection(adminDb, "locations", "loc-1", "broadcasts"), {
      locationId: "loc-1",
      name: "Main Hall Audio",
    }),
  );
});

test("any signed-in user can read broadcast profiles, but not delete them", async () => {
  await seedLocation("loc-1", {name: "Test Hall", status: "verified"});
  await seedAdmin("admin-1");
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "locations", "loc-1", "broadcasts", "b-1"), {
      locationId: "loc-1",
      name: "Main Hall Audio",
    });
  });

  const userDb = testEnv.authenticatedContext("user-1").firestore();
  const adminDb = testEnv.authenticatedContext("admin-1").firestore();

  await assertSucceeds(getDocs(collection(userDb, "locations", "loc-1", "broadcasts")));
  await assertFails(deleteDoc(doc(userDb, "locations", "loc-1", "broadcasts", "b-1")));
  await assertSucceeds(deleteDoc(doc(adminDb, "locations", "loc-1", "broadcasts", "b-1")));
});

test("sanity: rules file loaded", () => {
  assert.ok(testEnv, "test environment should be initialized");
});

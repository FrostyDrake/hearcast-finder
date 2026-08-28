const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

const CATEGORIES = [
  "cinema",
  "church",
  "museum",
  "school",
  "conference",
  "transport",
  "hospital",
  "other",
];
const STATUSES = ["candidate", "verified", "unknown"];

async function requireAdmin(auth) {
  if (!auth) {
    throw new HttpsError("unauthenticated", "You need to be signed in.");
  }
  const userDoc = await db.collection("users").doc(auth.uid).get();
  const role = userDoc.exists ? userDoc.data().role : null;
  if (role !== "admin") {
    throw new HttpsError("permission-denied", "Admin role required.");
  }
}

function validateLocationFields(data, {partial = false} = {}) {
  const errors = [];
  const required = ["name", "address", "city", "category", "latitude", "longitude"];

  if (!partial) {
    for (const field of required) {
      if (data[field] === undefined || data[field] === null || data[field] === "") {
        errors.push(`${field} is required`);
      }
    }
  }
  if (data.category !== undefined && !CATEGORIES.includes(data.category)) {
    errors.push("category is invalid");
  }
  if (data.status !== undefined && !STATUSES.includes(data.status)) {
    errors.push("status is invalid");
  }
  if (data.latitude !== undefined && typeof data.latitude !== "number") {
    errors.push("latitude must be a number");
  }
  if (data.longitude !== undefined && typeof data.longitude !== "number") {
    errors.push("longitude must be a number");
  }

  if (errors.length > 0) {
    throw new HttpsError("invalid-argument", errors.join(", "));
  }
}

exports.createLocation = onCall(async (request) => {
  await requireAdmin(request.auth);
  const data = request.data || {};
  validateLocationFields(data);

  const now = Date.now();
  const doc = {
    name: data.name,
    address: data.address,
    city: data.city,
    category: data.category,
    status: STATUSES.includes(data.status) ? data.status : "verified",
    latitude: data.latitude,
    longitude: data.longitude,
    notes: data.notes || "",
    ownerId: data.ownerId || "",
    createdBy: request.auth.uid,
    createdAt: now,
    updatedAt: now,
  };

  const ref = await db.collection("locations").add(doc);
  return {id: ref.id};
});

exports.updateLocation = onCall(async (request) => {
  await requireAdmin(request.auth);
  const data = request.data || {};
  const {locationId, ...changes} = data;

  if (!locationId) {
    throw new HttpsError("invalid-argument", "locationId is required");
  }
  validateLocationFields(changes, {partial: true});

  const ref = db.collection("locations").doc(locationId);
  const snapshot = await ref.get();
  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Location not found.");
  }

  await ref.update({
    ...changes,
    updatedAt: Date.now(),
    updatedBy: request.auth.uid,
  });
  return {id: locationId};
});

exports.deleteLocation = onCall(async (request) => {
  await requireAdmin(request.auth);
  const data = request.data || {};
  const {locationId} = data;

  if (!locationId) {
    throw new HttpsError("invalid-argument", "locationId is required");
  }

  const ref = db.collection("locations").doc(locationId);
  const snapshot = await ref.get();
  if (!snapshot.exists) {
    throw new HttpsError("not-found", "Location not found.");
  }

  await ref.delete();
  return {id: locationId};
});

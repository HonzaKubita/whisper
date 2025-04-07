-- CreateTable
CREATE TABLE "Package" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "forPublicKey" TEXT NOT NULL,
    "payload" TEXT NOT NULL
);

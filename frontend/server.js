// Ejecutar con node server.js dentro de la carpeta frontend

const express = require("express");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 8080;

app.use(express.static(__dirname));

app.get("/status", (req, res) => {
  let writable = true;
  try {
    fs.accessSync(__dirname, fs.constants.W_OK);
  } catch {
    writable = false;
  }

  res.json({
    status: "ok",
    uptime: process.uptime(),
    writable,
  });
});

app.listen(PORT, () => {
  console.log(`Frontend corriendo en http://localhost:${PORT}`);
});

// Ejecutar con node server.js dentro de la carpeta backend

const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

const filePath = path.join(__dirname, "operations.json");

function readOperations() {
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, "[]");
  }

  const data = fs.readFileSync(filePath, "utf-8");

  return JSON.parse(data);
}

function saveOperation(operation) {
  const operations = readOperations();

  operations.push(operation);

  fs.writeFileSync(filePath, JSON.stringify(operations, null, 2));
}

app.post("/add", (req, res) => {
  const { a, b } = req.body;

  const result = a + b;
  saveOperation({
    operation: "add",
    a,
    b,
    result,
    date: new Date().toISOString(),
  });

  res.status(201).json({
    message: "Suma realizada",
    result,
  });
});

app.post("/subtract", (req, res) => {
  const { a, b } = req.body;

  const result = a - b;
  saveOperation({
    operation: "subtract",
    a,
    b,
    result,
    date: new Date().toISOString(),
  });

  res.status(201).json({
    message: "Resta realizada",
    result,
  });
});

app.post("/multiply", (req, res) => {
  const { a, b } = req.body;

  const result = a * b;
  saveOperation({
    operation: "multiply",
    a,
    b,
    result,
    date: new Date().toISOString(),
  });

  res.status(201).json({
    message: "Multiplicación realizada",
    result,
  });
});


app.post("/divide", (req, res) => {
  const { a, b } = req.body;

  if (b === 0) {
    console.error(
      `[${new Date().toISOString()}] Error: división por cero (a=${a}, b=${b})`
    );
    return res.status(400).json({
      error: "División por cero no permitida",
    });
  }

  const result = a / b;
  saveOperation({
    operation: "divide",
    a,
    b,
    result,
    date: new Date().toISOString(),
  });

  res.status(201).json({
    message: "División realizada",
    result,
  });
});

app.get("/health", (req, res) => {
  let writable = true;
  try {
    fs.accessSync(filePath, fs.constants.W_OK);
  } catch {
    writable = false;
  }

  res.json({
    status: "ok",
    uptime: process.uptime(),
    writable,
  });
});

app.get("/operations", (req, res) => {
  const operations = readOperations();

  const lastFiveOperations = operations.slice(-5).reverse();

  res.json(lastFiveOperations);
});

app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});

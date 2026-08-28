async function calculate() {
  const serverUrl = "/api";

  const num1 = parseFloat(document.getElementById("num1").value);
  const num2 = parseFloat(document.getElementById("num2").value);
  const operation = document.getElementById("operation").value;

  if (isNaN(num1) || isNaN(num2)) {
    document.getElementById("info").innerText =
      "Por favor, ingrese números válidos.";
    return;
  }

  const endpoints = {
    add: "/add",
    subtract: "/subtract",
    multiply: "/multiply",
    divide: "/divide",
  };

  const endpoint = endpoints[operation];

  if (!endpoint) {
    document.getElementById("info").innerText =
      "Por favor, seleccione una operación válida.";
    return;
  }

  document.getElementById("info").innerText = "";
  document.getElementById("result").innerText = "";

  try {
    const response = await fetch(`${serverUrl}${endpoint}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        a: num1,
        b: num2,
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      document.getElementById("info").innerText =
        data.error || "Ocurrió un error al realizar la operación.";
      return;
    }

    document.getElementById("result").innerText = `Resultado: ${data.result}`;
  } catch (error) {
    console.error("Error:", error);
    document.getElementById("info").innerText =
      "Error al realizar la operación.";
  }
}

function formatStatus(label, data) {
  return `${label} → estado: ${data.status} | uptime: ${data.uptime.toFixed(
    1
  )}s | escritura habilitada: ${data.writable ? "sí" : "no"}`;
}

async function loadStatus() {
  const backendUrl = "/api";
  const statusInfo = document.getElementById("statusInfo");
  const lines = [];

  try {
    const response = await fetch("/status");
    const data = await response.json();
    lines.push(formatStatus("Frontend", data));
  } catch (error) {
    console.error("Error:", error);
    lines.push(
      "Frontend → no se pudo consultar (¿se abrió con node server.js?)."
    );
  }

  try {
    const response = await fetch(`${backendUrl}/health`);
    const data = await response.json();
    lines.push(formatStatus("Backend", data));
  } catch (error) {
    console.error("Error:", error);
    lines.push("Backend → no se pudo consultar (¿está corriendo?).");
  }

  statusInfo.innerHTML = lines.join("<br />");
}

async function loadHistory() {
  const serverUrl = "/api";

  try {
    const response = await fetch(`${serverUrl}/operations`);
    const operations = await response.json();

    const operationsList = document.getElementById("operationsList");
    operationsList.innerHTML = "";

    operations.forEach((op) => {
      const listItem = document.createElement("li");

      const operation = document.createElement("span");
      operation.textContent = `${op.a} ${getOperator(op.operation)} ${op.b} = ${op.result}`;

      const date = document.createElement("span");
      date.textContent = new Date(op.date).toLocaleString();

      operation.classList.add("operation");
      date.classList.add("operation-date");

      listItem.appendChild(operation);
      listItem.appendChild(date);

      operationsList.appendChild(listItem);
    });
  } catch (error) {
    console.error("Error:", error);
    document.getElementById("info").innerText =
      "Error al cargar el historial de operaciones.";
  }
}

function getOperator(operation) {
  switch (operation) {
    case "add":
      return "+";
    case "subtract":
      return "-";
    case "multiply":
      return "*";
    case "divide":
      return "/";
    default:
      return "";
  }
}

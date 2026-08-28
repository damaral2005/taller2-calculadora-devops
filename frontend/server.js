const express = require("express");
const fs = require("fs");

const app = express();

const PORT = process.env.PORT || 8080;
const BACKEND_URL =
  process.env.BACKEND_URL || "http://localhost:5000";

app.use(express.json());

app.use(express.static(__dirname));


// Proxy hacia el Backend
app.use("/api", async (req, res) => {

  const backendPath =
    req.originalUrl.replace(/^\/api/, "");

  const targetUrl =
    `${BACKEND_URL}${backendPath}`;

  try {

    const options = {
      method: req.method,
      headers: {},
    };

    if (!["GET", "HEAD"].includes(req.method)) {

      options.headers["Content-Type"] =
        "application/json";

      options.body =
        JSON.stringify(req.body);
    }

    const response =
      await fetch(targetUrl, options);

    const body =
      await response.text();

    const contentType =
      response.headers.get("content-type");

    if (contentType) {
      res.set("Content-Type", contentType);
    }

    res
      .status(response.status)
      .send(body);

  } catch (error) {

    console.error(
      `Error comunicando con backend: ${error.message}`
    );

    res.status(502).json({
      error: "Backend no disponible",
    });
  }

});


app.get("/status", (req, res) => {

  let writable = true;

  try {
    fs.accessSync(
      __dirname,
      fs.constants.W_OK
    );
  } catch {
    writable = false;
  }

  res.json({
    status: "ok",
    uptime: process.uptime(),
    writable,
  });

});


app.listen(PORT, "0.0.0.0", () => {

  console.log(
    `Frontend corriendo en http://0.0.0.0:${PORT}`
  );

  console.log(
    `Backend interno: ${BACKEND_URL}`
  );

});
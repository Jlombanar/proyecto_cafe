import 'dotenv/config'
import express from "express";
import { conectarDB } from "./db/db.js";
import userRoutes from "./routes/User.js";
import LoginUsers  from "./routes/Login.js";
import recuperarRoutes from "./routes/Recuperar.js";
import productosRoutes from "./routes/Productos.js";
import chatRoutes from "./routes/chatRoutes.js";
import path from "path";
import { fileURLToPath } from "url";
import cors from 'cors';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

  

const app = express();
app.use(cors());
conectarDB();
const PORT = 3000;
app.use(express.json());

// Sirve la carpeta uploads como archivos estáticos (para ver las imágenes de los productos)
app.use("/uploads", express.static(path.join(__dirname, "uploads")));



// Ruta básica
app.get("/", (req, res) => {
    res.send("Servidor funcionando 🚀");

});

app.get("/saludo", (req, res) => {
  res.json({
    mensaje: "¡Hola Aprendiz SENA! 👋",
    hora:    new Date().toLocaleTimeString()
  });
});

// Montando las rutas de la API
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// rutas de usuarios
app.use("/api/usuarios", userRoutes);
// rutas de login
app.use("/api/login",LoginUsers);

// ruta de recuperar contraseña
 app.use("/api/recuperar", recuperarRoutes);

 // Rutas de productos
app.use("/api/productos", productosRoutes);

// Ruta de chat
app.use("/api/chat", chatRoutes);

console.log('CLOUDINARY_CLOUD_NAME:', process.env.CLOUDINARY_CLOUD_NAME);
console.log('CLOUDINARY_API_KEY:', process.env.CLOUDINARY_API_KEY);
console.log('CLOUDINARY_API_SECRET:', process.env.CLOUDINARY_API_SECRET ? '(sí tiene valor)' : '(vacío / undefined)');
app.use((err, req, res, next) => {
  console.error('Error no manejado:', err.message);
  res.status(err.status || 500).json({
    message: err.message || 'Error interno del servidor',
  });
});
// Levantar servidor
app.listen(PORT, () => {
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
    
});
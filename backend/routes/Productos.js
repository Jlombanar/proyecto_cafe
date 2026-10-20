import { Router } from "express";
import {crearProducto,obtenerProductos,actualizarProducto,eliminarProducto} from "../controllers/Productos.js";
import { verificarToken, soloAdmin } from "../middlewares/authmiddleware.js";
import { upload } from "../middlewares/uploadmiddleware.js";
const router = Router();

// Definición de endpoints

router.get("/", obtenerProductos);

// solo los administradores pueden crear, actualizar y eliminar productos
// upload.single("imagen") procesa el archivo que llega en el campo "imagen" del formulario
router.post("/", verificarToken, soloAdmin, upload.single("imagen"), crearProducto);
router.put("/:id", verificarToken, soloAdmin, upload.single("imagen"), actualizarProducto);
router.delete("/:id", verificarToken, soloAdmin, eliminarProducto);

export default router;

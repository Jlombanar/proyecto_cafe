import express from "express";
import { solicitarCodigo,cambiarPassword } from "../controllers/Recuperar.js";

const router = express.Router();

// creamos la ruta
router.post("/solicitar-codigo", solicitarCodigo);
router.post("/cambiar-password", cambiarPassword);

export default router;
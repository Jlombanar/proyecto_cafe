import { Router } from "express";
import { crearPedido, misPedidos, cancelarMiPedido, listarPedidos, actualizarEstadoPedido } from "../controllers/Pedidos.js";
import { verificarToken, soloAdmin } from "../middlewares/authmiddleware.js";

const router = Router();

// Cliente
router.post("/", verificarToken, crearPedido);
router.get("/mis-pedidos", verificarToken, misPedidos);
router.put("/:id/cancelar", verificarToken, cancelarMiPedido);

// Administrador
router.get("/", verificarToken, soloAdmin, listarPedidos);
router.put("/:id/estado", verificarToken, soloAdmin, actualizarEstadoPedido);

export default router;

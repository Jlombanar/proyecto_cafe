import { Router } from "express";
import { obtenerNotificaciones, marcarLeida, marcarTodasLeidas } from "../controllers/Notificaciones.js";
import { verificarToken } from "../middlewares/authmiddleware.js";

const router = Router();

router.get("/", verificarToken, obtenerNotificaciones);
router.put("/leer-todas", verificarToken, marcarTodasLeidas);
router.put("/:id/leida", verificarToken, marcarLeida);

export default router;

import { Router } from "express";
import { obtenerFavoritos, alternarFavorito } from "../controllers/Favoritos.js";
import { verificarToken } from "../middlewares/authmiddleware.js";

const router = Router();

router.get("/", verificarToken, obtenerFavoritos);
router.post("/:productoId", verificarToken, alternarFavorito);

export default router;

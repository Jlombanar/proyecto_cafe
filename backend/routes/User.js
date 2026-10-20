import express from 'express';
// Importamos las funciones desde tu controlador
import { registrarUsers, verificarCuenta, reenviarCodigoVerificacion 
} from "../controllers/User.js";
import { loginWithGoogle } from "../controllers/google.js";

const router = express.Router();

// 1. Ruta para registrar al usuario y enviar el correo con los 6 dígitos
router.post("/registrar", registrarUsers);

// 2. Ruta para iniciar sesión con Google
router.post("/login-google", loginWithGoogle);

// 2. Ruta para que el usuario ingrese el código desde la pantalla y complete el registro
router.post("/verificar-codigo", verificarCuenta);

// 3. Ruta por si el código vence o no le llega y necesita uno nuevo
router.post("/reenviar-codigo", reenviarCodigoVerificacion);

export default router;
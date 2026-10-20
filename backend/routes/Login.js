import express from 'express';
import { LoginUsers } from "../controllers/Login.js";

const router= express.Router();

// ruta para el login de usuarios

router.post("/",LoginUsers);
export default router;
import { Router } from "express";
import { chatearConBarista } from "../controllers/chatController.js";

const router = Router();

// POST /api/chat
router.post("/", chatearConBarista);

export default router;
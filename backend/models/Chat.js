// models/Chat.js
import mongoose from "mongoose";

const chatSchema = new mongoose.Schema({
    usuarioId: { type: String, default: "anonimo" }, // o el ObjectId del usuario logueado
    pregunta: { type: String, required: true },
    respuestaIA: { type: String, required: true },
    fecha: { type: Date, default: Date.now }
});

export default mongoose.model("Chat", chatSchema);
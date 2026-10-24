import mongoose from "mongoose";

const notificacionSchema = new mongoose.Schema({
    usuario: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    titulo: { type: String, required: true },
    mensaje: { type: String, required: true },
    pedido: { type: mongoose.Schema.Types.ObjectId, ref: "Pedido" },
    leida: { type: Boolean, default: false },
}, { timestamps: true });

const Notificacion = mongoose.model("Notificacion", notificacionSchema, "Notificaciones");

export default Notificacion;

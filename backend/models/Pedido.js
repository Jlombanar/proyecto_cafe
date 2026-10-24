import mongoose from "mongoose";

export const ESTADOS_PEDIDO = ["pendiente", "confirmado", "preparando", "enviado", "entregado", "cancelado"];

// Cada item guarda una copia del nombre, precio e imagen del producto al momento
// de la compra, para que el pedido no cambie si luego se edita el producto.
const itemSchema = new mongoose.Schema({
    producto: { type: mongoose.Schema.Types.ObjectId, ref: "Productos", required: true },
    Nombre: { type: String, required: true },
    Precio: { type: Number, required: true },
    Image: { type: String, default: "" },
    cantidad: { type: Number, required: true, min: 1 },
}, { _id: false });

const pedidoSchema = new mongoose.Schema({
    usuario: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    items: { type: [itemSchema], required: true },
    total: { type: Number, required: true },

    // Datos del checkout
    direccion: { type: String, required: true, trim: true },
    ciudad: { type: String, required: true, trim: true },
    telefono: { type: String, required: true, trim: true },
    notas: { type: String, default: "", trim: true },
    metodoPago: { type: String, enum: ["contraentrega", "transferencia"], default: "contraentrega" },

    estado: { type: String, enum: ESTADOS_PEDIDO, default: "pendiente" },
}, { timestamps: true });

const Pedido = mongoose.model("Pedido", pedidoSchema, "Pedidos");

export default Pedido;

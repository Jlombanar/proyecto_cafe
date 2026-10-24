import mongoose from "mongoose";
import User from "../models/User.js";
import Productos from "../models/Productos.js";

// Lista los productos favoritos del usuario logueado
export const obtenerFavoritos = async (req, res) => {
    try {
        const usuario = await User.findById(req.usuario._id).populate("favoritos");
        // populate deja fuera los productos que ya fueron eliminados
        res.json(usuario.favoritos.filter(Boolean));
    } catch (error) {
        res.status(500).json({ message: "Error al obtener los favoritos" });
    }
};

// Agrega o quita un producto de favoritos (toggle)
export const alternarFavorito = async (req, res) => {
    try {
        const { productoId } = req.params;
        if (!mongoose.isValidObjectId(productoId) || !(await Productos.exists({ _id: productoId }))) {
            return res.status(404).json({ message: "Producto no encontrado" });
        }

        const yaEsFavorito = req.usuario.favoritos.some(id => id.toString() === productoId);
        const operacion = yaEsFavorito
            ? { $pull: { favoritos: productoId } }
            : { $addToSet: { favoritos: productoId } };

        const usuario = await User.findByIdAndUpdate(req.usuario._id, operacion, { returnDocument: "after" });

        res.json({
            message: yaEsFavorito ? "Eliminado de favoritos" : "Agregado a favoritos",
            esFavorito: !yaEsFavorito,
            favoritos: usuario.favoritos,
        });
    } catch (error) {
        res.status(500).json({ message: "Error al actualizar favoritos", error: error.message });
    }
};

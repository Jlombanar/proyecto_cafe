import Notificacion from "../models/Notificacion.js";

// Notificaciones del usuario logueado (las 50 más recientes)
export const obtenerNotificaciones = async (req, res) => {
    try {
        const notificaciones = await Notificacion.find({ usuario: req.usuario._id })
            .sort({ createdAt: -1 })
            .limit(50);
        res.json(notificaciones);
    } catch (error) {
        res.status(500).json({ message: "Error al obtener las notificaciones" });
    }
};

export const marcarLeida = async (req, res) => {
    try {
        await Notificacion.updateOne({ _id: req.params.id, usuario: req.usuario._id }, { leida: true });
        res.json({ message: "Notificación leída" });
    } catch (error) {
        res.status(500).json({ message: "Error al actualizar la notificación" });
    }
};

export const marcarTodasLeidas = async (req, res) => {
    try {
        await Notificacion.updateMany({ usuario: req.usuario._id, leida: false }, { leida: true });
        res.json({ message: "Notificaciones leídas" });
    } catch (error) {
        res.status(500).json({ message: "Error al actualizar las notificaciones" });
    }
};

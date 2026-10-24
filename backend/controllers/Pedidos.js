import mongoose from "mongoose";
import Pedido, { ESTADOS_PEDIDO } from "../models/Pedido.js";
import Productos from "../models/Productos.js";
import User from "../models/User.js";
import Notificacion from "../models/Notificacion.js";
import {
    enviarConfirmacionPedido,
    enviarAvisoNuevoPedidoAdmin,
    enviarCambioEstadoPedido,
    ETIQUETAS_ESTADO,
} from "../utils/mailer.js";

const codigoPedido = (pedido) => pedido._id.toString().slice(-6).toUpperCase();

// Los correos no deben tumbar la compra si Brevo falla: solo se registra el error
const enviarSinBloquear = (promesa, descripcion) => {
    promesa.catch((error) =>
        console.error(`Error enviando correo (${descripcion}):`, error?.body || error?.message || error)
    );
};

// Crear pedido (checkout del usuario)
export const crearPedido = async (req, res) => {
    try {
        const { items, direccion, ciudad, telefono, notas, metodoPago } = req.body;

        if (!Array.isArray(items) || items.length === 0) {
            return res.status(400).json({ message: "El carrito está vacío" });
        }
        if (!direccion || !ciudad || !telefono) {
            return res.status(400).json({ message: "Dirección, ciudad y teléfono son obligatorios" });
        }

        const ids = items.map(i => i.productoId);
        if (!ids.every(id => mongoose.isValidObjectId(id))) {
            return res.status(400).json({ message: "Hay productos inválidos en el carrito" });
        }

        // Los precios se toman de la BD, nunca del cliente
        const productos = await Productos.find({ _id: { $in: ids } });
        const porId = new Map(productos.map(p => [p._id.toString(), p]));

        const itemsPedido = [];
        for (const item of items) {
            const producto = porId.get(item.productoId);
            const cantidad = parseInt(item.cantidad, 10);
            if (!producto) {
                return res.status(400).json({ message: "Uno de los productos ya no está disponible" });
            }
            if (!cantidad || cantidad < 1) {
                return res.status(400).json({ message: "Cantidad inválida" });
            }
            itemsPedido.push({
                producto: producto._id,
                Nombre: producto.Nombre,
                Precio: producto.Precio,
                Image: producto.Image,
                cantidad,
            });
        }

        const total = itemsPedido.reduce((suma, i) => suma + i.Precio * i.cantidad, 0);

        const pedido = await Pedido.create({
            usuario: req.usuario._id,
            items: itemsPedido,
            total,
            direccion,
            ciudad,
            telefono,
            notas,
            metodoPago,
        });

        // Notificaciones dentro de la app: al cliente y a cada administrador
        const admins = await User.find({ rol: "admin" });
        await Notificacion.insertMany([
            {
                usuario: req.usuario._id,
                titulo: "Pedido recibido",
                mensaje: `Tu pedido #${codigoPedido(pedido)} está pendiente de confirmación.`,
                pedido: pedido._id,
            },
            ...admins.map(admin => ({
                usuario: admin._id,
                titulo: "Nuevo pedido pendiente",
                mensaje: `${req.usuario.Nombre} ${req.usuario.Apellido} hizo el pedido #${codigoPedido(pedido)}.`,
                pedido: pedido._id,
            })),
        ]);

        // Correos
        enviarSinBloquear(enviarConfirmacionPedido(req.usuario, pedido), "confirmación al cliente");
        admins.forEach(admin =>
            enviarSinBloquear(enviarAvisoNuevoPedidoAdmin(admin, req.usuario, pedido), "aviso al admin")
        );

        res.status(201).json({ message: "Pedido realizado con éxito", pedido });
    } catch (error) {
        console.error("Error al crear el pedido", error);
        res.status(500).json({ message: "Error al crear el pedido", error: error.message });
    }
};

// Pedidos del usuario logueado
export const misPedidos = async (req, res) => {
    try {
        const pedidos = await Pedido.find({ usuario: req.usuario._id }).sort({ createdAt: -1 });
        res.json(pedidos);
    } catch (error) {
        res.status(500).json({ message: "Error al obtener tus pedidos" });
    }
};

// El usuario puede cancelar su pedido solo mientras esté pendiente
export const cancelarMiPedido = async (req, res) => {
    try {
        const pedido = await Pedido.findOne({ _id: req.params.id, usuario: req.usuario._id });
        if (!pedido) {
            return res.status(404).json({ message: "Pedido no encontrado" });
        }
        if (pedido.estado !== "pendiente") {
            return res.status(400).json({ message: "Solo se pueden cancelar pedidos pendientes" });
        }

        pedido.estado = "cancelado";
        await pedido.save();

        const admins = await User.find({ rol: "admin" }, "_id");
        await Notificacion.insertMany(admins.map(admin => ({
            usuario: admin._id,
            titulo: "Pedido cancelado",
            mensaje: `El cliente canceló el pedido #${codigoPedido(pedido)}.`,
            pedido: pedido._id,
        })));

        res.json({ message: "Pedido cancelado", pedido });
    } catch (error) {
        res.status(500).json({ message: "Error al cancelar el pedido", error: error.message });
    }
};

// Admin: todos los pedidos, opcionalmente filtrados por estado (?estado=pendiente)
export const listarPedidos = async (req, res) => {
    try {
        const filtro = {};
        if (req.query.estado) filtro.estado = req.query.estado;

        const pedidos = await Pedido.find(filtro)
            .populate("usuario", "Nombre Apellido Correo_Electronico telefono")
            .sort({ createdAt: -1 });
        res.json(pedidos);
    } catch (error) {
        res.status(500).json({ message: "Error al obtener los pedidos" });
    }
};

// Admin: cambiar el estado de un pedido y avisar al cliente
export const actualizarEstadoPedido = async (req, res) => {
    try {
        const { estado } = req.body;
        if (!ESTADOS_PEDIDO.includes(estado)) {
            return res.status(400).json({ message: `Estado inválido. Usa: ${ESTADOS_PEDIDO.join(", ")}` });
        }

        const pedido = await Pedido.findById(req.params.id).populate("usuario");
        if (!pedido) {
            return res.status(404).json({ message: "Pedido no encontrado" });
        }
        if (pedido.estado === estado) {
            return res.json({ message: "El pedido ya tiene ese estado", pedido });
        }

        pedido.estado = estado;
        await pedido.save();

        if (pedido.usuario) {
            await Notificacion.create({
                usuario: pedido.usuario._id,
                titulo: `Pedido ${ETIQUETAS_ESTADO[estado].toLowerCase()}`,
                mensaje: `Tu pedido #${codigoPedido(pedido)} ahora está: ${ETIQUETAS_ESTADO[estado]}.`,
                pedido: pedido._id,
            });
            enviarSinBloquear(enviarCambioEstadoPedido(pedido.usuario, pedido), "cambio de estado");
        }

        res.json({ message: "Estado actualizado", pedido });
    } catch (error) {
        console.error("Error al actualizar el estado", error);
        res.status(500).json({ message: "Error al actualizar el estado", error: error.message });
    }
};

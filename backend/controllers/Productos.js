import Productos from "../models/Productos.js";
import { borrarImagenCloudinary } from "../utils/cloudinary.js";



// Crear producto
export const crearProducto = async (req, res) => {
    try {
        const { Nombre, Descripcion, Precio } = req.body;

        if (!Nombre || !Descripcion || !Precio) {
            return res.status(400).json({ message: "Nombre, descripción y precio son obligatorios" });
        }

        if (!req.file) {
            return res.status(400).json({ message: "Debes subir una imagen del producto" });
        }

        const newProduct = new Productos({
            productId: `PROD-${Date.now()}`,
            Nombre,
            Descripcion,
            Precio: parseInt(Precio, 10),
            Image: req.file.path, // URL provista por Cloudinary
        });

        await newProduct.save();

        res.status(201).json({ message: "Producto guardado con éxito", producto: newProduct });
    } catch (error) {
        console.error("Error al guardar el producto", error);
        res.status(400).json({
            message: "Error al ingresar el producto",
            error: error.message,
        });
    }
};

// Obtener todos los productos
export const obtenerProductos = async (req, res) => {
    try {
        const listarProductos = await Productos.find();
        res.status(200).json(listarProductos);
    } catch (error) {
        res.status(500).json({ message: "Error al obtener los productos" });
    }
};

// Actualizar producto
export const actualizarProducto = async (req, res) => {
    try {
        const { id } = req.params;

        const producto = await Productos.findById(id);
        if (!producto) {
            return res.status(404).json({ message: "Producto no encontrado" });
        }

        const { Nombre, Descripcion, Precio } = req.body;
        producto.Nombre = Nombre ?? producto.Nombre;
        producto.Descripcion = Descripcion ?? producto.Descripcion;
        producto.Precio = Precio ? parseInt(Precio, 10) : producto.Precio;

        // Si se envía una nueva imagen, borra la actual en Cloudinary y guarda la nueva
        if (req.file) {
            await borrarImagenCloudinary(producto.Image);
            producto.Image = req.file.path;
        }

        await producto.save();

        res.json({ message: "Producto actualizado", productoActualizado: producto });
    } catch (error) {
        console.error("Error al actualizar el producto", error);
        res.status(400).json({ message: "Error al actualizar producto", error: error.message });
    }
};

// Eliminar producto y su imagen en Cloudinary
export const eliminarProducto = async (req, res) => {
    try {
        const { id } = req.params;

        const productoEliminado = await Productos.findByIdAndDelete(id);

        if (!productoEliminado) {
            return res.status(404).json({ message: "Producto no encontrado" });
        }

        await borrarImagenCloudinary(productoEliminado.Image);

        res.json({ message: "Producto eliminado correctamente" });
    } catch (error) {
        res.status(400).json({ message: "Error al eliminar producto", error: error.message });
    }
};
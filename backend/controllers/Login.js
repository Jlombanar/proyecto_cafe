import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/User.js";

// Creamos el controlador de login
export const LoginUsers = async (req, res) => {
    try {
        const { Correo_Electronico, passwords } = req.body;

        // 1. Validamos los campos
        if (!Correo_Electronico || !passwords) {
            return res.status(400).json({ message: "Por favor, ingrese su correo electrónico y contraseña" });
        }

        // 2. Buscamos el usuario en la base de datos
        const Usuario = await User.findOne({ Correo_Electronico });
        
        // CORREGIDO: Usar 'Usuario' en lugar de 'User'
        if (!Usuario) {
            return res.status(400).json({ message: "Usuario no encontrado" });
        }

        // 3. Validamos la contraseña
        // CORREGIDO: Usar 'Usuario.passwords' (asegúrate de que en tu Schema se llame 'passwords' o 'password')
        const esValida = await bcrypt.compare(passwords, Usuario.passwords);
        if (!esValida) {
            return res.status(400).json({ message: "Contraseña incorrecta" });
        }

        // 3. NUEVA VALIDACIÓN: Bloquear si no ha verificado el código
    if (!Usuario.isVerified) {
      return res.status(403).json({ 
        message: "Tu cuenta no está verificada. Por favor ingresa el código enviado a tu correo antes de iniciar sesión." 
      });
    }

        // 4. Generamos el token de autenticación
        // CORREGIDO: Usar las propiedades de 'Usuario'
        const token = jwt.sign(
            { id: Usuario._id, Correo_Electronico: Usuario.Correo_Electronico },
            process.env.JWT_SECRET,
            { expiresIn: "1h" }
        );

        // 5. Respondemos con el token y los datos del usuario
        res.status(200).json({
            message: "Inicio de sesión exitoso",
            token: token,
            usuario: {
                _id: Usuario._id,
                Correo_Electronico: Usuario.Correo_Electronico,
                Apellido: Usuario.Apellido, 
                Nombre: Usuario.Nombre,
                rol: Usuario.rol
            }
        });

    } catch (error) {
        res.status(500).json({ message: "Error del login", error: error.message });
    }
};
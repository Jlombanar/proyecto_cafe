import User from "../models/User.js";
import { enviarCodigoVerificacion } from "../utils/mailer.js";

// 1. REGISTRO Y ENVÍO DEL CÓDIGO
export const registrarUsers = async (req, res) => {
  try {
    const { Nombre, Apellido, telefono, Correo_Electronico, passwords } = req.body;

    // Validación de campos vacíos
    if (!Nombre || !Apellido || !telefono || !Correo_Electronico || !passwords) {
      return res.status(400).json({ message: "Todos los campos son obligatorios" });
    }

    // Verificar si el correo ya existe
    const existeUser = await User.findOne({ Correo_Electronico });
    if (existeUser) {
      return res.status(400).json({ message: "El correo electrónico ya está registrado" });
    }

    // Generar código de 6 dígitos y vencimiento a 15 minutos
    const codigo = Math.floor(100000 + Math.random() * 900000).toString();
    const expiracion = new Date(Date.now() + 15 * 60 * 1000);

    // Guardar usuario inactivo
    const nuevoUser = new User({
      Nombre,
      Apellido,
      telefono,
      Correo_Electronico,
      passwords,
      codigoVerificacion: codigo,
      codigoVerificacionExpiracion: expiracion,
      isVerified: false
    });

    await nuevoUser.save();

    // Enviar el correo
    await enviarCodigoVerificacion(Correo_Electronico, Nombre, codigo);

    res.status(200).json({
      message: "Hemos enviado un código de 6 dígitos a su correo para completar el registro.",
      correo: Correo_Electronico
    });

  } catch (error) {
    console.error("Error en registro:", error);
    res.status(500).json({ message: "Error interno al registrar el usuario" });
  }
};

// 2. VERIFICACIÓN DEL CÓDIGO EN PANTALLA
export const verificarCuenta = async (req, res) => {
  try {
    const { Correo_Electronico, codigo } = req.body;

    if (!Correo_Electronico || !codigo) {
      return res.status(400).json({ message: "El correo y el código son obligatorios" });
    }

    const user = await User.findOne({ Correo_Electronico });

    if (!user) {
      return res.status(404).json({ message: "Usuario no encontrado" });
    }

    if (user.isVerified) {
      return res.status(400).json({ message: "Esta cuenta ya ha sido verificada" });
    }

    if (user.codigoVerificacion !== codigo.trim()) {
      return res.status(400).json({ message: "El código ingresado es incorrecto" });
    }

    if (user.codigoVerificacionExpiracion < new Date()) {
      return res.status(400).json({ message: "El código ha expirado. Solicite uno nuevo." });
    }

    // Activar usuario y limpiar campos
    user.isVerified = true;
    user.codigoVerificacion = undefined;
    user.codigoVerificacionExpiracion = undefined;
    await user.save();

    res.status(200).json({
      message: "¡Su registro fue exitoso! Ya puede iniciar sesión."
    });

  } catch (error) {
    console.error("Error en verificación:", error);
    res.status(500).json({ message: "Error interno al verificar la cuenta" });
  }
};

// 3. REENVIAR CÓDIGO SI EXPIRÓ O NO LLEGÓ
export const reenviarCodigoVerificacion = async (req, res) => {
  try {
    const { Correo_Electronico } = req.body;

    if (!Correo_Electronico) {
      return res.status(400).json({ message: "El correo electrónico es requerido" });
    }

    const user = await User.findOne({ Correo_Electronico });

    if (!user) {
      return res.status(404).json({ message: "No existe una cuenta con este correo" });
    }

    if (user.isVerified) {
      return res.status(400).json({ message: "Esta cuenta ya se encuentra verificada" });
    }

    // Nuevo código y renovación a 15 minutos
    const nuevoCodigo = Math.floor(100000 + Math.random() * 900000).toString();
    user.codigoVerificacion = nuevoCodigo;
    user.codigoVerificacionExpiracion = new Date(Date.now() + 15 * 60 * 1000);
    await user.save();

    await enviarCodigoVerificacion(user.Correo_Electronico, user.Nombre, nuevoCodigo);

    res.status(200).json({
      message: "Se ha enviado un nuevo código de 6 dígitos a su correo."
    });

  } catch (error) {
    console.error("Error al reenviar código:", error);
    res.status(500).json({ message: "Error interno al reenviar el código" });
  }
};
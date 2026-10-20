import { OAuth2Client } from "google-auth-library";
import jwt from "jsonwebtoken";
import User from "../models/User.js";

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export const loginWithGoogle = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ message: "El token de Google es requerido" });
    }

    let googleId, email, given_name, family_name, picture;

    // Un JWT siempre tiene exactamente 3 partes: header.payload.signature
    // Un Access Token de Google suele empezar por "ya29." o no tener 3 partes
    const esJwt = idToken.split(".").length === 3 && !idToken.startsWith("ya29.");

    if (esJwt) {
      // Flujo Móvil (Android / iOS)
      const ticket = await client.verifyIdToken({
        idToken,
        audience:
          process.env.GOOGLE_CLIENT_ID ||
          "941062996232-1a5p710a19q68e895ma6htiokch286p4.apps.googleusercontent.com",
      });

      const payload = ticket.getPayload();
      googleId = payload.sub;
      email = payload.email;
      given_name = payload.given_name;
      family_name = payload.family_name;
      picture = payload.picture;
    } else {
      // Flujo Flutter Web (Access Token: ya29...)
      const userInfoResponse = await fetch(
        "https://www.googleapis.com/oauth2/v3/userinfo",
        {
          headers: { Authorization: `Bearer ${idToken}` },
        }
      );

      if (!userInfoResponse.ok) {
        const errData = await userInfoResponse.text();
        console.error("Error en Google userinfo:", errData);
        throw new Error("El access token de Google no es válido o expiró");
      }

      const userData = await userInfoResponse.json();
      googleId = userData.sub;
      email = userData.email;
      given_name = userData.given_name || userData.name || "USUARIO";
      family_name = userData.family_name || "";
      picture = userData.picture;
    }

    if (!email) {
      return res
        .status(400)
        .json({ message: "Google no proporcionó un correo electrónico válido" });
    }

    const correoLimpio = email.toLowerCase().trim();

    let usuario = await User.findOne({ Correo_Electronico: correoLimpio });

    if (usuario) {
      if (!usuario.googleId) usuario.googleId = googleId;
      if (!usuario.isVerified) {
        usuario.isVerified = true;
        usuario.codigoVerificacion = undefined;
        usuario.codigoVerificacionExpiracion = undefined;
      }
      if (!usuario.avatar && picture) usuario.avatar = picture;
      await usuario.save();
    } else {
      usuario = new User({
        Nombre: given_name || "USUARIO",
        Apellido: family_name || "",
        Correo_Electronico: correoLimpio,
        googleId,
        avatar: picture || "",
        isVerified: true,
        rol: "usuario",
      });

      await usuario.save();
    }

    const token = jwt.sign(
      { id: usuario._id, Correo_Electronico: usuario.Correo_Electronico },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    return res.status(200).json({
      message: "Inicio de sesión con Google exitoso",
      token,
      usuario: {
        _id: usuario._id,
        Correo_Electronico: usuario.Correo_Electronico,
        Apellido: usuario.Apellido,
        Nombre: usuario.Nombre,
        rol: usuario.rol,
        avatar: usuario.avatar,
      },
    });
  } catch (error) {
    console.error("Error al autenticar con Google:", error);
    return res.status(401).json({
      message: "Token de Google inválido o expirado",
      error: error.message,
    });
  }
};
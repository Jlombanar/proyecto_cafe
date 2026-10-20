import User from "../models/User.js";
import { BrevoClient } from "@getbrevo/brevo";
import dotenv from "dotenv";

dotenv.config();

// Inicializar el cliente oficial de Brevo
const brevo = new BrevoClient({
    apiKey: process.env.BREVO_API_KEY,
});

// Función para generar un código numérico de 6 dígitos
const generarCode = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

// Función para solicitar el código de recuperación
export const solicitarCodigo = async (req, res) => {
    try {
        const { Correo_Electronico } = req.body;

        if (!Correo_Electronico) {
            return res.status(400).json({ message: "El correo electrónico es requerido" });
        }

        const emailNormalizado = Correo_Electronico.toLowerCase().trim();

        // Buscar el usuario por correo electrónico
        const usuario = await User.findOne({ Correo_Electronico: emailNormalizado });
        if (!usuario) {
            return res.status(404).json({ message: "Usuario no encontrado" });
        }

        // Generar código y vigencia (15 minutos = 900000 ms)
        const codigo = generarCode();
        usuario.codigoRecuperacion = codigo;
        usuario.codigoexpiracion = Date.now() + 900000;
        await usuario.save();

        const htmlContent = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #333333;">
            <div style="text-align: center; margin-bottom: 30px;">
                <h2 style="color: #4F46E5; margin: 0;">🛍️ TechStore Pro</h2>
            </div>

            <h3 style="color: #333333;">Recuperación de Contraseña</h3>

            <p>Hola <strong>${usuario.Nombre || "Usuario"}</strong>,</p>

            <p>Recibimos una solicitud para restablecer tu contraseña.</p>

            <p>Tu código de verificación es:</p>

            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        padding: 25px 20px;
                        border-radius: 10px;
                        text-align: center;
                        margin: 25px 0;">

                <h1 style="color: #ffffff;
                           font-size: 34px;
                           letter-spacing: 8px;
                           margin: 0;
                           font-family: 'Courier New', Courier, monospace;">
                    ${codigo}
                </h1>
            </div>

            <p style="color: #666666; font-size: 14px;">
                ⏱️ Este código expirará en <strong>15 minutos</strong>.
            </p>

            <p style="color: #666666; font-size: 14px;">
                🔒 Si no solicitaste este cambio, ignora este mensaje y tu contraseña permanecerá segura.
            </p>

            <hr style="margin: 30px 0; border: none; border-top: 1px solid #dddddd;">

            <p style="color: #999999; font-size: 12px; text-align: center;">
                © 2026 TechStore Pro - Tu tienda de tecnología de confianza
            </p>
        </div>
        `;

        // Enviar con el SDK de Brevo
        await brevo.transactionalEmails.sendTransacEmail({
            subject: "Código de recuperación - TechStore Pro",
            sender: {
                name: "TechStore Pro",
                email: process.env.EMAIL_USER
            },
            to: [
                {
                    email: usuario.Correo_Electronico,
                    name: usuario.Nombre || "Usuario"
                }
            ],
            htmlContent: htmlContent
        });

        res.status(200).json({ message: "Código de recuperación enviado al correo electrónico" });

    } catch (error) {
        console.error("Error al solicitar el código de recuperación:", error);
        res.status(500).json({ 
            message: "Error al solicitar el código de recuperación", 
            error: error.message 
        });
    }
};

// Función para cambiar la contraseña
export const cambiarPassword = async (req, res) => {
    try {
        const { Correo_Electronico, codigo, nuevaPassword } = req.body;

        if (!Correo_Electronico || !codigo || !nuevaPassword) {
            return res.status(400).json({ message: "Todos los campos son requeridos" });
        }

        if (nuevaPassword.length < 6) {
            return res.status(400).json({ message: "La nueva contraseña debe tener al menos 6 caracteres" });
        }

        const emailNormalizado = Correo_Electronico.toLowerCase().trim();

        // Buscar el usuario con código vigente
        const usuario = await User.findOne({
            Correo_Electronico: emailNormalizado,
            codigoRecuperacion: codigo,
            codigoexpiracion: { $gt: Date.now() }
        });

        if (!usuario) {
            return res.status(400).json({ message: "Código de recuperación inválido o expirado" });
        }

        // Actualizar contraseña y limpiar campos temporales
        usuario.passwords = nuevaPassword;
        usuario.codigoRecuperacion = null;
        usuario.codigoexpiracion = null;

        await usuario.save();

        const htmlContent = `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #333;">
                <div style="text-align: center; margin-bottom: 30px;">
                    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                                width: 55px;
                                height: 55px;
                                border-radius: 50%;
                                display: inline-flex;
                                align-items: center;
                                justify-content: center;
                                margin-bottom: 15px;">
                        <span style="color: white; font-size: 28px; line-height: 55px;">✓</span>
                    </div>
                    <h2 style="color: #4F46E5; margin: 0;">Contraseña Actualizada</h2>
                </div>

                <p>Hola <strong>${usuario.Nombre || "Usuario"}</strong>,</p>

                <p>Tu contraseña ha sido <strong style="color: #22C55E;">actualizada exitosamente</strong> en TechStore Pro.</p>

                <p style="margin-top: 20px; padding: 15px; background: #f0fdf4; border-left: 4px solid #22C55E; border-radius: 4px;">
                    ✅ Ya puedes iniciar sesión con tu nueva contraseña.
                </p>

                <p style="color: #666; font-size: 14px; margin-top: 20px;">
                    <strong>💡 Por tu seguridad:</strong>
                </p>
                <ul style="color: #666; font-size: 14px; line-height: 1.6;">
                    <li>Cierra sesión en otros dispositivos</li>
                    <li>No compartas tu contraseña con nadie</li>
                    <li>Usa una contraseña única para cada sitio</li>
                </ul>

                <p style="color: #dc2626; font-size: 14px; margin-top: 20px;">
                    ⚠️ <strong>Si no realizaste este cambio,</strong> contacta a soporte inmediatamente:<br>
                    📧 soporte@techstore.com
                </p>

                <hr style="margin: 30px 0; border: none; border-top: 1px solid #ddd;">

                <p style="color: #999; font-size: 12px; text-align: center;">
                    © 2026 TechStore Pro - Tu tienda de tecnología de confianza
                </p>
            </div>
        `;

        // Enviar notificación de cambio de contraseña
        await brevo.transactionalEmails.sendTransacEmail({
            subject: "Contraseña cambiada - TechStore Pro",
            sender: {
                name: "TechStore Pro",
                email: process.env.EMAIL_USER
            },
            to: [
                {
                    email: usuario.Correo_Electronico,
                    name: usuario.Nombre || "Usuario"
                }
            ],
            htmlContent: htmlContent
        });

        res.status(200).json({ message: "Contraseña cambiada exitosamente" });

    } catch (error) {
        console.error("Error al cambiar la contraseña:", error);
        res.status(500).json({ 
            message: "Error al cambiar la contraseña", 
            error: error.message 
        });
    }
};
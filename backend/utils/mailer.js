import { BrevoClient } from '@getbrevo/brevo';

const brevo = new BrevoClient({
  apiKey: process.env.BREVO_API_KEY,
});

export const enviarCodigoVerificacion = async (correo, nombre, codigo) => {
  try {
    const result = await brevo.transactionalEmails.sendTransacEmail({
      subject: "¡Gracias por registrarte! Confirma tu cuenta",
      sender: { 
        name: "Mi tienda de cafe", 
        email: process.env.EMAIL_USER 
      },
      to: [
        { 
          email: correo, 
          name: nombre 
        }
      ],
      htmlContent: `
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 500px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
          <h2 style="color: #4a2c11; text-align: center;">¡Hola, ${nombre}!</h2>
          <p>Gracias por registrarte en nuestra plataforma.</p>
          <p>Para completar tu registro y activar tu cuenta, ingresa el siguiente código de 6 dígitos:</p>
          <div style="background-color: #f7f3ee; color: #4a2c11; padding: 15px; font-size: 26px; font-weight: bold; letter-spacing: 6px; text-align: center; border-radius: 6px; margin: 20px 0; border: 1px dashed #c2a68d;">
            ${codigo}
          </div>
          <p style="font-size: 13px; color: #777;">Este código vencerá en <strong>15 minutos</strong>.</p>
          <p style="font-size: 12px; color: #999; margin-top: 20px;">Si no creaste esta cuenta, puedes ignorar este mensaje.</p>
        </div>
      `
    });

    return result;
  } catch (error) {
    console.error("Error enviando correo con Brevo:", error);
    throw error;
  }
};

// ---------- Correos de pedidos ----------

const formatoCOP = (valor) => `$${Number(valor).toLocaleString("es-CO")} COP`;

const ETIQUETAS_ESTADO = {
  pendiente: "Pendiente",
  confirmado: "Confirmado",
  preparando: "En preparación",
  enviado: "Enviado",
  entregado: "Entregado",
  cancelado: "Cancelado",
};

const tablaItems = (pedido) => `
  <table style="width: 100%; border-collapse: collapse; margin: 16px 0;">
    ${pedido.items.map(item => `
      <tr style="border-bottom: 1px solid #eee;">
        <td style="padding: 8px 0;">${item.Nombre} x ${item.cantidad}</td>
        <td style="padding: 8px 0; text-align: right;">${formatoCOP(item.Precio * item.cantidad)}</td>
      </tr>
    `).join("")}
    <tr>
      <td style="padding: 12px 0; font-weight: bold;">Total</td>
      <td style="padding: 12px 0; text-align: right; font-weight: bold; color: #4a2c11;">${formatoCOP(pedido.total)}</td>
    </tr>
  </table>
`;

const plantilla = (contenido) => `
  <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 500px; margin: auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
    ${contenido}
    <p style="font-size: 12px; color: #999; margin-top: 20px; text-align: center;">Café Místico ☕</p>
  </div>
`;

const enviarCorreo = (correo, nombre, subject, htmlContent) =>
  brevo.transactionalEmails.sendTransacEmail({
    subject,
    sender: { name: "Mi tienda de cafe", email: process.env.EMAIL_USER },
    to: [{ email: correo, name: nombre }],
    htmlContent,
  });

// Al cliente: confirmación de que su compra fue recibida
export const enviarConfirmacionPedido = (usuario, pedido) =>
  enviarCorreo(
    usuario.Correo_Electronico,
    usuario.Nombre,
    `¡Recibimos tu pedido #${pedido._id.toString().slice(-6).toUpperCase()}!`,
    plantilla(`
      <h2 style="color: #4a2c11; text-align: center;">¡Gracias por tu compra, ${usuario.Nombre}!</h2>
      <p>Recibimos tu pedido <strong>#${pedido._id.toString().slice(-6).toUpperCase()}</strong> y está <strong>pendiente</strong> de confirmación.</p>
      ${tablaItems(pedido)}
      <p><strong>Entrega:</strong> ${pedido.direccion}, ${pedido.ciudad}<br>
         <strong>Teléfono:</strong> ${pedido.telefono}<br>
         <strong>Pago:</strong> ${pedido.metodoPago === "transferencia" ? "Transferencia" : "Contra entrega"}</p>
      <p style="font-size: 13px; color: #777;">Te avisaremos por correo cada vez que cambie el estado de tu pedido.</p>
    `)
  );

// Al administrador: aviso de nueva compra pendiente
export const enviarAvisoNuevoPedidoAdmin = (admin, usuario, pedido) =>
  enviarCorreo(
    admin.Correo_Electronico,
    admin.Nombre,
    `Nuevo pedido pendiente #${pedido._id.toString().slice(-6).toUpperCase()}`,
    plantilla(`
      <h2 style="color: #4a2c11;">Nuevo pedido pendiente</h2>
      <p><strong>Cliente:</strong> ${usuario.Nombre} ${usuario.Apellido} (${usuario.Correo_Electronico})</p>
      ${tablaItems(pedido)}
      <p>Ingresa al panel administrativo para gestionarlo.</p>
    `)
  );

// Al cliente: su pedido cambió de estado
export const enviarCambioEstadoPedido = (usuario, pedido) =>
  enviarCorreo(
    usuario.Correo_Electronico,
    usuario.Nombre,
    `Tu pedido #${pedido._id.toString().slice(-6).toUpperCase()} está: ${ETIQUETAS_ESTADO[pedido.estado]}`,
    plantilla(`
      <h2 style="color: #4a2c11; text-align: center;">Actualización de tu pedido</h2>
      <p>Hola ${usuario.Nombre}, tu pedido <strong>#${pedido._id.toString().slice(-6).toUpperCase()}</strong> cambió de estado:</p>
      <div style="background-color: #f7f3ee; color: #4a2c11; padding: 15px; font-size: 22px; font-weight: bold; text-align: center; border-radius: 6px; margin: 20px 0; border: 1px dashed #c2a68d;">
        ${ETIQUETAS_ESTADO[pedido.estado]}
      </div>
      ${tablaItems(pedido)}
    `)
  );

export { ETIQUETAS_ESTADO };

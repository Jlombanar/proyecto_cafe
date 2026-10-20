import Groq from "groq-sdk";
import Productos from "../models/Productos.js";

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

let catalogoEnMemoria = null;

export const invalidarCacheCatalogo = () => {
    catalogoEnMemoria = null;
};

const obtenerCatalogo = async () => {
    if (catalogoEnMemoria) return catalogoEnMemoria;

    const productos = await Productos.find({}, "Nombre Descripcion Precio").lean();
    if (!productos || productos.length === 0) return "";

    catalogoEnMemoria = productos.map(p => 
        `- **${p.Nombre}**: $${p.Precio.toLocaleString("es-CO")} COP | Descripción: ${p.Descripcion}`
    ).join("\n");

    return catalogoEnMemoria;
};

export const chatearConBarista = async (req, res) => {
    try {
        const { mensaje } = req.body;

        if (!mensaje || !mensaje.trim()) {
            return res.status(400).json({ message: "Debes enviar un mensaje." });
        }

        const catalogo = await obtenerCatalogo();

        if (!catalogo) {
            return res.status(200).json({
                respuesta: "¡Hola! En este momento no tenemos productos registrados en la tienda."
            });
        }

        const systemPrompt = `
Eres el barista y asesor virtual experto de nuestra tienda de café. Eres cálido, educado y muy natural.

CATÁLOGO DISPONIBLE:
${catalogo}

PAUTAS DE ATENCIÓN:
1. SALUDOS INICIALES: Si el cliente únicamente saluda o pregunta cómo estás (ej: "Hola", "Buenas", "¿Cómo vas?"), responde amablemente:
   "¡Hola! Muy bien, gracias por preguntar. ¡Bienvenido a nuestra tienda! ☕ ¿En qué te puedo colaborar hoy?"
   NUNCA envíes el catálogo de productos si no lo han pedido.

2. LISTADO DE CAFÉS Y PRECIOS: Si preguntan qué cafés hay disponibles o los precios, entrégalos en base al catálogo con el valor exacto en pesos colombianos ($ COP).

3. RECOMENDACIONES: Si piden sugerencias, utiliza las descripciones para orientarlo según sus gustos.

4. PRODUCTOS FUERA DEL CATÁLOGO: Si preguntan por productos no disponibles (capuchinos, postres, etc.), aclara amablemente que por ahora no los manejas y ofrece los cafés de la lista.

5. Sé siempre conciso y completa tus respuestas.
`;

        // Usamos el modelo conversacional activo en tu cuenta
        const completion = await groq.chat.completions.create({
            model: "openai/gpt-oss-20b",
            messages: [
                { role: "system", content: systemPrompt },
                { role: "user", content: mensaje }
            ],
            temperature: 0.3,
            max_tokens: 500,
        });

        const respuestaTexto = completion.choices[0]?.message?.content || "No pude generar una respuesta.";

        return res.status(200).json({
            respuesta: respuestaTexto
        });

    } catch (error) {
        console.error("Error en Groq Chat:", error);
        return res.status(500).json({
            message: "Error al procesar la respuesta del barista",
            error: error.message
        });
    }
};
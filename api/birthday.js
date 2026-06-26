const NOTION_API = "https://api.notion.com/v1/pages";
const NOTION_VERSION = "2022-06-28";

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const { name, birthdate, contact } = req.body ?? {};

  // Validación mínima
  if (!name || typeof name !== "string" || name.trim().length === 0) {
    return res.status(400).json({ error: "El nombre es requerido" });
  }
  if (!birthdate || typeof birthdate !== "string") {
    return res.status(400).json({ error: "La fecha es requerida" });
  }

  const token = process.env.NOTION_TOKEN;
  const databaseId = process.env.NOTION_DATABASE_ID;

  if (!token || !databaseId) {
    console.error("Faltan variables de entorno NOTION_TOKEN o NOTION_DATABASE_ID");
    return res.status(500).json({ error: "Configuración incompleta en el servidor" });
  }

  try {
    const notionRes = await fetch(NOTION_API, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        "Notion-Version": NOTION_VERSION,
      },
      body: JSON.stringify({
        parent: { database_id: databaseId },
        properties: {
          // "Nombre" es la columna Title (la primera por defecto)
          Nombre: {
            title: [{ text: { content: name.trim().slice(0, 100) } }],
          },
          Fecha: {
            date: { start: birthdate },
          },
          Contacto: {
            rich_text: [
              { text: { content: (contact ?? "").trim().slice(0, 200) } },
            ],
          },
          Registrado: {
            date: { start: new Date().toISOString() },
          },
        },
      }),
    });

    if (!notionRes.ok) {
      const err = await notionRes.json().catch(() => ({}));
      console.error("Notion API error:", notionRes.status, err);
      return res.status(502).json({ error: "No se pudo guardar en Notion" });
    }

    return res.status(200).json({ ok: true });
  } catch (err) {
    console.error("Error inesperado:", err);
    return res.status(500).json({ error: "Error interno del servidor" });
  }
}

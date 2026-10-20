import multer from 'multer';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import cloudinary from '../config/cloudinary.js';
 

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'cafe-mistico/productos', 
    allowed_formats: ['jpg', 'jpeg', 'png', 'avif', 'webp'],
    transformation: [{ width: 800, height: 800, crop: 'limit' }], // evita imágenes gigantes
  },
});
 
const filtroImagenes = (req, file, cb) => {
  const tiposPermitidos = ['image/jpeg', 'image/png', 'image/webp'];
  if (tiposPermitidos.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Solo se permiten imágenes (jpg, jpeg, png, webp)'), false);
  }
};
 
export const upload = multer({
  storage,
  fileFilter: filtroImagenes,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB máximo
});
 
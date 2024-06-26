import os
import shutil
import dicom2jpg
import config as cf


def save_dicom_uploads(file):
    file_dir = os.path.join(cf.base_dir, "data", "uploads", file.filename)
    file.save(file_dir)
    return file_dir


def convert_dicom_to_img(file_path):
    target_dir = os.path.join(cf.base_dir, "data", "raw")
    dicom2jpg.dicom2jpg(file_path, target_root=target_dir)
    return target_dir


def copy_dicom_to_uploads(file_name, file_path):
    dt_file_path = os.path.join(cf.base_dir, "data", "uploads", file_name)
    if os.path.isfile(file_path):
        shutil.copy(file_path, dt_file_path)
    
    return dt_file_path
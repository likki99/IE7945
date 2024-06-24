import os
from pydicom import dcmread

def get_dicom_stats(folder_path):
  """
  This function reads DICOM images from a folder and calculates various statistics.

  Args:
      folder_path: Path to the folder containing DICOM images.

  Returns:
      A dictionary containing statistics about the DICOM images.
  """
  stats = {
      "total_files": 0,
      "modalities_data": {},
      "image_shapes": [],
      "pixel_types": {}
  }

  for root, _, filenames in os.walk(folder_path):
    for filename in filenames:
      if filename.lower().endswith(".dcm"):
        filepath = os.path.join(root, filename)
        try:
          dcm = dcmread(filepath)
          stats["total_files"] += 1

          # Update modality statistics
          modality = dcm.Modality.upper()
          stats["modalities"][modality] = stats["modalities"].get(modality, 0) + 1

          # Update image shape statistics
          stats["image_shapes"].append(dcm.pixel_array.shape)

          # Update pixel type statistics
          pixel_type = dcm.PixelRepresentation
          stats["pixel_types"][pixel_type] = stats["pixel_types"].get(pixel_type, 0) + 1

        except IOError as e:
          print(f"Error reading DICOM file: {filepath}")

  return stats

if __name__ == "__main__":
  # Replace 'path/to/your/folder' with the actual path to your DICOM folder
  folder_path = "/Users/likhithravula/Documents/NEU/Northeastern/Capstone/NBIA Source Data/Raw/Pseudo-PHI-DICOM-Data"
  stats = get_dicom_stats(folder_path)

  print("DICOM Image Statistics:")
  print(f"Total Files: {stats['total_files']}")

  print("Modalities:")
  for modality, count in stats["modalities"].items():
    print(f"\t- {modality}: {count}")

  print("Image Shapes:")
  # You can print individual shapes or calculate summary statistics here
  #  print(stats["image_shapes"])

  print("Pixel Types:")
  for pixel_type, count in stats["pixel_types"].items():
    print(f"\t- {pixel_type}: {count}")


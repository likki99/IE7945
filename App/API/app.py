import logging
import psutil
import time
from subprocess import Popen
import mysql.connector
from flask import Flask, request, jsonify
import mysql.connector
import os
from pydicom import dcmread
from collections import Counter

# from logging_module import LoggingHandler

app = Flask(__name__)


# def get_logger():
#     name = "api_logs"
#     current_date = str(datetime.now().strftime("dt_%Y-%m-%d"))
#     log_file = open("/home/aman_kumar01/data/hl7_tool/logs/api_logs_{}.log".format(current_date), "a")
#     # logger = LoggingHandler(name, log_file)
#     return logger, log_file


def success_message(response, msg):
    msg_dict = {"data": response, "flag": 1, "message": msg}
    return msg_dict


def failed_message(error, msg):
    msg_dict = {"flag": 0, "message": msg, "errInfo": error}
    return msg_dict


def is_service_running(script_path):
    for process in psutil.process_iter():
        if process.cmdline() == ["python3", script_path]:
            print("Service is Running")
            return True
    return False


def stop_service(script_path):
    if not is_service_running(script_path):
        logging.info("Service is stopped already")
        return True
    else:
        logging.info("Stopping the Service")
        for process in psutil.process_iter():
            if process.cmdline() == ["python3", script_path]:
                process.terminate()
                break
        time.sleep(3)
        if not is_service_running(script_path):
            logging.info("Service stopped Successfully")
            return True
        else:
            logging.info("Failed to stop the Service")
            return False


def start_service(script_path):
    if is_service_running(script_path):
        logging.info("Service already Running")
        return True
    else:
        logging.info("Starting the Service")
        Popen(["python3", script_path])
        time.sleep(3)
        if is_service_running(script_path):
            logging.info("Service Started Successfully")
            return True
        else:
            logging.error("Failed to Start the service")
            return False


@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    # Connect to MySQL database
    cnx = mysql.connector.connect(
        user="root", password="AkkiLikki@9799", host="localhost", database="capstone"
    )
    cursor = cnx.cursor()

    query = "SELECT * FROM CREDENTIALS WHERE USERNAME = %s AND PASSWORD = %s"
    cursor.execute(query, (username, password))

    result = cursor.fetchone()

    cursor.close()
    cnx.close()

    if result:
        name = result[2]
        return jsonify({"message": "Login successful", "name": name}), 200
    else:
        return jsonify({"message": "Invalid credentials"}), 401


@app.route("/stats", methods=["GET"])
def get_dicom_stats():
    """
    This function reads DICOM images from a folder and calculates various statistics.

    Args:
        folder_path: Path to the folder containing DICOM images.

    Returns:
        A dictionary containing statistics about the DICOM images.
    """
    folder_path = "/Users/likhithravula/Documents/NEU/Northeastern/Capstone/NBIA Source Data/Raw/Pseudo-PHI-DICOM-Data"
    try:
        stats = {
            "total_files": 0,
            "modalities": {},
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

        modalities_count = []
        for key in stats["modalities"].keys():
            count = {}
            count["name"] = key
            count["value"] = stats["modalities"][key]
            modalities_count.append(count)

        
        image_shapes = Counter(stats["image_shapes"])

        image_shapes_count = []
        for key, value in image_shapes.items():
            count = {}
            count["name"] = key
            count["value"] = value
            image_shapes_count.append(count)

        response_body = {
            "total_files": stats["total_files"],
            "modalities_count": modalities_count,
            "image_shapes": image_shapes_count,
            "pixel_types": stats["pixel_types"]
        }

        return jsonify(response_body), 200
    except Exception as e:
        print(e)
        return jsonify({"message": "Error happened at the server", "error": str(e)}), 500



# service_name can be DICOM or EMR or FHIR
@app.route("/services/<name>/tasks/<task>")
def control_service(name, task):
    try:
        # logger, log_file = get_logger()
        logging.info("{} {}".format(task, name))
        if name == "dicom":
            file_path = "/app/dicom-service.py"  # can get from env variable also
        else:
            # log_file.close()
            return (
                failed_message(
                    "{} Service is invalid or not listed".format(name),
                    "Invalid Service",
                ),
                500,
            )

        info_msg = ""
        err_msg = ""
        title = ""
        if task == "start":
            if is_service_running(file_path):
                info_msg = "{} Service is already Running".format(name)
                title = "Already Running"
            else:
                if start_service(file_path):
                    info_msg = "{} Service started Successfully".format(name)
                    title = "Service Started"
                else:
                    err_msg = "{} Service failed to Start".format(name)
                    title = "Service failed to Start"

        elif task == "stop":
            if not is_service_running(file_path):
                info_msg = "{} Service is already Stopped".format(name)
                title = "Already Stopped"
            else:
                if stop_service(file_path):
                    info_msg = "{} Service Stopped Successfully".format(name)
                    title = "Service Stopped"
                else:
                    err_msg = "{} Service failed to Stop".format(name)
                    title = "Service Failed to Stop"

        elif task == "status":
            if is_service_running(file_path):
                info_msg = "{} Service is Running".format(name)
                title = "Service Running"
            else:
                info_msg = "{} Service is Stopped".format(name)
                title = "Service Stopped"

        elif task == "restart":
            if is_service_running(file_path):
                if stop_service(file_path):
                    if start_service(file_path):
                        info_msg = "{} Service Restarted Successfully".format(name)
                        title = "Service Restarted"
                    else:
                        err_msg = "{} Service Failed to Restart".format(name)
                        title = "Service Failed to Restart"
                else:
                    err_msg = "Failed to Stop {} service".format(name)
                    title = "Service Failed to Stop"

            else:
                if start_service(file_path):
                    info_msg = "{} Service was Stopped, Started Successfully".format(
                        name
                    )
                    title = "Service Started"
                else:
                    err_msg = "Failed to Start {} stopped service".format(name)
                    title = "Failed to Start Service"
        else:
            err_msg = "{} is Invalid Command, should be start, stop, status or restart".format(
                task
            )
            title = "Invalid Task"

        if info_msg:
            # log_file.close()
            return success_message(info_msg, title), 200
        else:
            # log_file.close()
            return failed_message(err_msg, title), 500

    except Exception as e:
        logging.error("Internal Exception Error: {}".format(e))
        # log_file.close()
        return (
            failed_message(
                "Internal Exception Error: {}".format(e), "Internal Exception Error"
            ),
            500,
        )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8001, debug=True)

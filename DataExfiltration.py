import os
import base64
import shutil
import datetime
from tkinter import Tk, Button, messagebox
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

# Define the target folder
shared_folder = r"C:\demo-data"

# Simulated remote paths (adjust for your VM2 setup)
vm2_share_path = r"Z:\\"         # Simulated lateral movement target
vm2_exfil_path = r"Y:\\"    # Simulated exfiltration drop zone

# Check if folder exists, if not create it
if not os.path.exists(shared_folder):
    try:
        os.makedirs(shared_folder)
        print(f"Created folder: {shared_folder}")
    except Exception as e:
        print(f"Failed to create folder: {shared_folder}\n{str(e)}")
else:
    print(f"Folder already exists: {shared_folder}")

# Generate or load AES-256 key
key_path = os.path.join(shared_folder, "aes256_key.key")
if not os.path.exists(key_path):
    key = os.urandom(32)  # 256-bit key
    with open(key_path, "wb") as key_file:
        key_file.write(key)
else:
    with open(key_path, "rb") as key_file:
        key = key_file.read()

backend = default_backend()

def encrypt_data(data):
    iv = os.urandom(16)  # 128-bit IV
    padder = padding.PKCS7(128).padder()
    padded_data = padder.update(data) + padder.finalize()
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=backend)
    encryptor = cipher.encryptor()
    encrypted = encryptor.update(padded_data) + encryptor.finalize()
    return base64.b64encode(iv + encrypted)

def decrypt_data(encoded_data):
    raw_data = base64.b64decode(encoded_data)
    iv = raw_data[:16]
    encrypted = raw_data[16:]
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv), backend=backend)
    decryptor = cipher.decryptor()
    decrypted_padded = decryptor.update(encrypted) + decryptor.finalize()
    unpadder = padding.PKCS7(128).unpadder()
    return unpadder.update(decrypted_padded) + unpadder.finalize()

def create_files():
    try:
        for i in range(1, 21):
            file_path = os.path.join(shared_folder, f"file_{i}.txt")
            with open(file_path, "w") as f:
                f.write(f"This is dummy file number {i}")
        messagebox.showinfo("Success", "20 dummy files created.")
    except Exception as e:
        messagebox.showerror("Error", f"Failed to create files.\n{str(e)}")

def encrypt_files():
    try:
        for i in range(1, 21):
            old_name = os.path.join(shared_folder, f"file_{i}.txt")
            new_name = os.path.join(shared_folder, f"file_{i}_renamed.txt")
            if os.path.exists(old_name):
                os.rename(old_name, new_name)
                with open(new_name, "rb") as file:
                    data = file.read()
                encrypted_data = encrypt_data(data)
                with open(new_name, "wb") as file:
                    file.write(encrypted_data)

        confirmation_file = os.path.join(shared_folder, "test_confirmation.txt")
        with open(confirmation_file, "w") as f:
            f.write("All 20 files were renamed and encrypted successfully.")
        
        log_event("Encryption: 20 files renamed and encrypted.")
        messagebox.showinfo("Done", "Files renamed, encrypted, and confirmation file created.")
    except Exception as e:
        messagebox.showerror("Error", f"Encryption failed.\n{str(e)}")

def decrypt_files():
    try:
        for i in range(1, 21):
            file_path = os.path.join(shared_folder, f"file_{i}_renamed.txt")
            if os.path.exists(file_path):
                with open(file_path, "rb") as file:
                    encoded_data = file.read()
                decrypted_data = decrypt_data(encoded_data)
                with open(file_path, "wb") as file:
                    file.write(decrypted_data)
        log_event("Decryption: 20 files decrypted.")
        messagebox.showinfo("Success", "Files decrypted successfully.")
    except Exception as e:
        messagebox.showerror("Error", f"Decryption failed.\n{str(e)}")

def remove_files():
    try:
        removed = 0
        for filename in os.listdir(shared_folder):
            if filename.startswith("file_") or filename == "test_confirmation.txt":
                os.remove(os.path.join(shared_folder, filename))
                removed += 1
        log_event(f"Cleanup: {removed} files removed.")
        messagebox.showinfo("Cleanup", f"{removed} files removed.")
    except Exception as e:
        messagebox.showerror("Error", f"File removal failed.\n{str(e)}")

def simulate_lateral_movement():
    try:
        os.makedirs(vm2_share_path, exist_ok=True)
        moved = 0
        for filename in os.listdir(shared_folder):
            if filename.endswith("_renamed.txt"):
                src = os.path.join(shared_folder, filename)
                dst = os.path.join(vm2_share_path, filename)
                shutil.copy2(src, dst)
                moved += 1
        log_event(f"Lateral movement: {moved} files copied to VM2 share.")
        messagebox.showinfo("Lateral Movement", f"{moved} files copied to VM2.")
    except Exception as e:
        messagebox.showerror("Error", f"Lateral movement failed.\n{str(e)}")

def simulate_data_exfiltration():
    try:
        os.makedirs(vm2_exfil_path, exist_ok=True)
        exfiltrated = 0
        for filename in os.listdir(shared_folder):
            if filename.endswith("_renamed.txt"):
                src = os.path.join(shared_folder, filename)
                dst = os.path.join(vm2_exfil_path, filename)
                shutil.copy2(src, dst)
                exfiltrated += 1
        log_path = os.path.join(vm2_exfil_path, "exfiltration_log.txt")
        with open(log_path, "a") as log:
            log.write(f"{datetime.datetime.now()}: Exfiltrated {exfiltrated} files from VM1\n")
        log_event(f"Data exfiltration: {exfiltrated} files sent to VM2 exfil folder.")
        messagebox.showinfo("Data Exfiltration", f"{exfiltrated} files exfiltrated to VM2.")
    except Exception as e:
        messagebox.showerror("Error", f"Data exfiltration failed.\n{str(e)}")

def log_event(event):
    log_file = os.path.join(shared_folder, "attack_log.txt")
    with open(log_file, "a") as log:
        log.write(f"{datetime.datetime.now()}: {event}\n")

# GUI setup
root = Tk()
root.title("CredLock AES-256 Simulation")
root.geometry("300x350")

btn_create = Button(root, text="Create Dummy Files", command=create_files, width=25)
btn_create.pack(pady=5)

btn_encrypt = Button(root, text="Rename & Encrypt Files", command=encrypt_files, width=25)
btn_encrypt.pack(pady=5)

btn_decrypt = Button(root, text="Undo Encryption", command=decrypt_files, width=25)
btn_decrypt.pack(pady=5)

btn_remove = Button(root, text="Remove Dummy Files", command=remove_files, width=25)
btn_remove.pack(pady=5)

btn_lateral = Button(root, text="Simulate Lateral Movement", command=simulate_lateral_movement, width=25)
btn_lateral.pack(pady=5)

btn_exfil = Button(root, text="Simulate Data Exfiltration", command=simulate_data_exfiltration, width=25)
btn_exfil.pack(pady=5)

root.mainloop()

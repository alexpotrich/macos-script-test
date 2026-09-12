import os
import sys
import zipfile
import subprocess

from PIL import Image
from pypdf import PdfReader


ROOT = sys.argv[1]


def check_image(path):
    try:
        with Image.open(path) as img:
            img.verify()

        return True, "Image valide"

    except Exception as e:
        return False, str(e)


def check_pdf(path):
    try:
        reader = PdfReader(path)

        for page in reader.pages:
            _ = page.mediabox

        return True, f"PDF valide ({len(reader.pages)} pages)"

    except Exception as e:
        return False, str(e)


def check_zip(path):
    try:
        with zipfile.ZipFile(path, "r") as z:

            bad = z.testzip()

            if bad:
                return False, f"Entrée ZIP corrompue : {bad}"

        return True, "Archive ZIP valide"

    except Exception as e:
        return False, str(e)


def check_media(path):
    try:
        result = subprocess.run(
            [
                "ffprobe",
                "-v", "error",
                "-show_entries",
                "format=format_name,duration",
                "-of",
                "default=noprint_wrappers=1",
                path
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        if result.returncode == 0:

            info = result.stdout.strip()

            if info:
                info = info.replace("\n", " | ")
            else:
                info = "Média lisible"

            return True, info

        return False, result.stderr.strip()

    except Exception as e:
        return False, str(e)


def check_text(path):
    try:
        with open(path, "rb") as f:
            data = f.read()

        if len(data) == 0:
            return True, "Fichier texte vide mais valide"

        try:
            text = data.decode("utf-8")
        except UnicodeDecodeError as e:
            return False, f"UTF-8 invalide : {e}"

        if "\x00" in text:
            return False, "Présence d'octets NULL"

        allowed_controls = "\n\r\t"

        bad_controls = sum(
            1
            for c in text
            if ord(c) < 32 and c not in allowed_controls
        )

        ratio = bad_controls / max(len(text), 1)

        if ratio > 0.01:
            return False, (
                f"Trop de caractères de contrôle "
                f"({bad_controls}, {ratio:.2%})"
            )

        return True, f"Texte UTF-8 valide ({len(data)} octets)"

    except Exception as e:
        return False, str(e)


print()
print("============================================================")
print("               CONTROLE D'INTEGRITE")
print("============================================================")
print()

invalid = 0
checked = 0


for root, dirs, files in os.walk(ROOT):

    for filename in sorted(files):

        path = os.path.join(root, filename)

        ext = os.path.splitext(filename)[1].lower()

        relative = os.path.relpath(path, ROOT)

        result = None


        # Images
        if ext in [
            ".jpg",
            ".jpeg",
            ".png",
            ".gif",
            ".bmp",
            ".webp"
        ]:

            result = check_image(path)


        # PDF
        elif ext == ".pdf":

            result = check_pdf(path)


        # ZIP
        elif ext == ".zip":

            result = check_zip(path)


        # Audio / vidéo
        elif ext in [
            ".mp3",
            ".mp4",
            ".m4a",
            ".mov",
            ".wav",
            ".aac",
            ".flac"
        ]:

            result = check_media(path)


        # Texte
        elif ext in [
            ".txt",
            ".log",
            ".md"
        ]:

            result = check_text(path)


        if result:

            checked += 1

            valid, message = result

            if valid:
                status = "OK"

            else:
                status = "CORROMPU"
                invalid += 1

            print(f"[{status:8}] {relative}")
            print(f"           {message}")
            print()


print("============================================================")
print(f"Fichiers contrôlés : {checked}")
print(f"Fichiers invalides : {invalid}")
print("============================================================")

sys.exit(0)

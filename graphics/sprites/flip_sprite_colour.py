from PIL import Image
import os

def invert_colors(image_path, output_path):
    # Open the image
    img = Image.open(image_path)

    # Separate the alpha channel (transparency) if exists
    if img.mode in ('RGBA', 'LA') or (img.mode == 'P' and 'transparency' in img.info):
        r, g, b, a = img.split()
        inverted_img = Image.merge('RGBA', (Image.eval(r, lambda x: 255 - x),
                                           Image.eval(g, lambda x: 255 - x),
                                           Image.eval(b, lambda x: 255 - x),
                                           a))
    else:
        inverted_img = Image.eval(img, lambda x: 255 - x)

    # Save the inverted image
    inverted_img.save(output_path)

if __name__ == "__main__":
    # Get the current script directory
    script_directory = os.path.dirname(os.path.abspath(__file__))

    # Loop through each PNG file in the script directory
    for filename in os.listdir(script_directory):
        if filename.endswith(".png"):
            input_path = os.path.join(script_directory, filename)
            output_path = os.path.join(script_directory, filename.replace(".png", "_black.png"))

            # Invert colors and save the image
            invert_colors(input_path, output_path)

    print("Color inversion complete.")

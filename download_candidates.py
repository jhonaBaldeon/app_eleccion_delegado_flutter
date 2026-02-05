import urllib.request
import os

directory = 'assets/candidatos'
if not os.path.exists(directory):
    os.makedirs(directory)

for i in range(1, 5):
    url = f'https://picsum.photos/seed/candidate{i}/150/150'
    filename = f'candidate{i}.png'
    filepath = os.path.join(directory, filename)
    try:
        urllib.request.urlretrieve(url, filepath)
        print(f'Descargado: {filename}')
    except Exception as e:
        print(f'Error al descargar {filename}: {e}')

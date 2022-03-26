# TesterCMD-Installer
Installer source code for a GTA SA:MP mod.



## Compilare:
Folderul `moonloader` trebuie adaugat intr-o arhiva zip ce va fi numita `testercmd.zip`.<br>
Pentru compilare sau rulare este nevoie de un [Python Interpreter](https://www.python.org/downloads/). Acesta poate fi descarcat de la link-ul anterior, iar la instalare trebuie adaugat in PATH-ul sistemului.<br>![image](https://user-images.githubusercontent.com/44036462/160235183-4c8c8c78-4fa8-4cbb-9caf-40bafcdc7604.png)<br>

Installer-ul va fi compilat folosind [`pyinstaller`](https://pyinstaller.readthedocs.io/en/stable/). Acesta poate fi instalat folosind `pip install pyinstaller`. Dupa instalarea pachetului, il rulam folosind argumentele `--onefile --windowed` si specificand locatia codului sursa.<br>Rezultatul comenzii ar trebui sa arate asa:<br>
> ![image](https://user-images.githubusercontent.com/44036462/160234794-e35e6673-7754-47e9-8063-1d5ecd8e6302.png)<br>


Dupa compilare, executabilul rezultat il putem gasi in folderul `dist`. Langa acesta copiem si arhiva creata anterior, dupa care putem rula installer-ul.<br>


> ![image](https://user-images.githubusercontent.com/44036462/160234943-0ab964f1-55fd-4cf9-b2c0-6e517c870410.png)


## Rularea folosind interpreter-ul:
Alternativa compilarii este rulatul folosind [interpreter-ul](https://www.python.org/downloads/) mentionat anterior. Instalam pachetele necesare folosind `pip install -r requirements.txt`, ne asiguram ca arhiva creata anterior se afla in acelasi directory cu cel al installer-ului, dupa care putem rula installer-ul folosind `python installer.py` 


## Copierea manuala a fisierelor
O alternativa a installer-ului este copiatul manual al fisierelor. Copiem folderul `moonloader` in folderul cu jocul, deschidem fisierul `faction_name.txt` din folderul `moonloader/TesterADV` si modificam numele factiunii din acesta. Ne asiguram ca avem cleo, sampfuncs si moonloader instalate, dupa care putem folosi mod-ul.

from sys import path
import PySimpleGUI as sg
import winreg
import zipfile
import os

sg.theme('Gray Gray Gray')

requirements = ["cleo.asi", 'lua51.dll', 'moonloader.asi', 'sampfuncs.asi']
faction_list = {
    "Los Santos Police Department":"LSPD",
    "Las Venturas Police Department":"LVPD",
    "San Fierro Police Department":"SFPD",
    "FBI":"FBI",
    "National Guard":"National Guard",
    "Taxi Las Venturas":"Taxi LV",
    "Taxi Los Santos":"Taxi LS",
    "Taxi San Fierro":"Taxi SF",
    "Paramedic Department LS":"Paramedic LS",
    "Paramedic Department LV":"Paramedic LV",
    "Paramedic Department SF":"Paramedic SF",
    "School Instructors LV":"School Instructors LV",
    "School Instructors SF":"School Instructors SF",
    "News Reporters":"News Reporters",
    "Hitman":"Hitman",
    "Los Aztecas":"Los Aztecas",
    "Grove Street":"Grove Street",
    "Crips Gang":"Crips Gang",
    "Ballas":"Ballas",
    "Red Dragon Triads":"Red Dragon Triads",
    "The Russian Mafia":"The Russian Mafia",
    "San Fierro Rifa":"San Fierro Rifa",
    "The Italian Mafia":"The Italian Mafia",
    "Da Nang Boys":"Da Nang Boys",
    "Tow Car Company LS":"TCC LS",
    "Tow Car Company LV":"TCC LV"}
# Gasim path-ul jocului la HKEY_CURRENT_USER\Software\SAMP\gta_sa_exe REG_SZ

def read_reg(k = 'gta_sa_exe'):
    try:
        path = winreg.HKEY_CURRENT_USER
        key = winreg.OpenKeyEx(path, r"SOFTWARE\\SAMP\\")
        value = winreg.QueryValueEx(key,k)
        if key:
            winreg.CloseKey(key)
        return value[0]
    except Exception as e:
        print(e)
    return None

def create_file_if_not_exists(file_name, content, forced = False):
    if forced and os.path.exists(file_name):
        os.remove(file_name)
        print("Removed file: " + file_name)
    if not os.path.exists(file_name):
        print("File doesn't exist", file_name)

        print(file_name)
        with open(file_name, 'w') as f:
            f.write(content)

default_game_path = read_reg() or None

layout = [[sg.Text('Numele factiunii:')],
          [sg.Combo(values=list(faction_list),default_value="Los Santos Police Department", key='_listbox_', readonly=True)],
          [sg.Text('Locatia jocului (gta_sa.exe):')],
          [sg.Input(default_text=default_game_path), sg.FileBrowse()],
          [sg.OK(button_text="Install", button_color="green"), sg.Cancel()]]

window = sg.Window('TesterCMD Installer', layout)

try:
    event, values = window.read()
    print(event, values)
    if event == 'Install':
        path_to_game = ''.join(os.path.split(values[0])[:-1]) # Folderul in care se afla gta_sa.exe

        if values['_listbox_'] == []:
            sg.popup('Selecteaza o factiune!')
            exit()
        else:
            factiune = values['_listbox_']
            print(factiune)
            create_file_if_not_exists(path_to_game+'\\moonloader\\TesterCMD\\faction_name.txt', f"{factiune}\n{faction_list[factiune]}", True)
            create_file_if_not_exists(path_to_game+'\\moonloader\\TesterCMD\\intrebari.txt', f"Ce face {factiune}?\nCum iei FW?") # Template pentru a sti baietii cum sa faca txt-urile
            create_file_if_not_exists(path_to_game+'\\moonloader\\TesterCMD\\raspunsuri.txt', f"Joaca SAMP.\nFac DM.") # Template pentru a sti baietii cum sa faca txt-urile
            create_file_if_not_exists(path_to_game+'\\moonloader\\TesterCMD\\timpiDeRaspuns.txt', "10\n60")
        
        with zipfile.ZipFile('testercmd.zip', 'r') as zip_ref:
            zip_ref.extractall(path_to_game)

        # Check if requirements are met, if not, specify which are not met
        if not all(os.path.exists(os.path.join(path_to_game, i)) for i in requirements):
            requirements_not_met = [i for i in requirements if not os.path.exists(os.path.join(path_to_game, i))]
            sg.popup_error('TesterCMD a fost instalat, insa, functionabilitatea nu este garantata deoarece lipseste:', *requirements_not_met)
            exit()
        sg.popup('TesterCMD a fost instalat cu succes!')
    
    window.close()

except Exception as e:
    text_to_send = f'Unexpected error occured:\n' + e.__str__()
    print(e)
    sg.popup_error(text_to_send)
    window.close()
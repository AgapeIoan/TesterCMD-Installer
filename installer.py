from sys import path
import PySimpleGUI as sg
import winreg
import zipfile
import os

sg.theme('Default')

requirements = ["cleo.asi", 'lua51.dll', 'moonloader.asi', 'sampfuncs.asi']
faction_list = ["Taxi Los Santos", "Taxi Las Venturas", "Taxi San Fierro"]
faction_list_scurt = ["Taxi LS", "Taxi LV", "Taxi SF"]
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

def update_faction_name(faction_name):
    with open('faction_name.txt', 'w') as f:
        f.write(faction_name + '\n')
        f.write(faction_list_scurt[faction_list.index(faction_name)])
    zip = zipfile.ZipFile('testercmd.zip','a')
    zip.write('faction_name.txt', 'moonloader\\TesterCMD\\faction_name.txt')
    zip.close()
    os.remove('faction_name.txt')

default_game_path = read_reg() or None

layout = [[sg.Text('Numele factiunii:')],
          [sg.Listbox(values=faction_list, size=(30, 3), key='_listbox_')],
          [sg.Text('Game path:')],
          [sg.Input(default_text=default_game_path), sg.FileBrowse()],
          [sg.OK(button_text="Install"), sg.Cancel()]]

window = sg.Window('TesterCMD Installer', layout)

try:
    event, values = window.read()
    print(event, values)
    if event == 'Install':
        if values['_listbox_'] == []:
            sg.popup('Selecteaza o factiune!')
            exit()
        else:
            factiune = values['_listbox_'][0]
            update_faction_name(factiune)
        path_to_game = ''.join(os.path.split(values[0])[:-1]) # Folderul in care se afla gta_sa.exe

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
    sg.popup_error(text_to_send)
    window.close()
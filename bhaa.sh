#!/bin/bash
# [bhaa.sh]
# Kelola Basic HTTP Authentication Apache2 secara otomatis.

trap 'echo -e "\n[-] KeyboardInterrupt"; exit 1' SIGINT

# Fungsi untuk cek root
function cek_root(){
	if [[ $EUID -ne 0 ]]; then
		echo "[-] Script ini harus dijalankan sebagai root."
		exit 1
	fi
}

# Fungsi tekan enter
function tekan_enter(){
	echo ""
	read -p "Tekan [Enter] untuk kembali ke menu utama..."
}

# Fungsi untuk keluar program
function keluar(){
	echo "[*] Semoga harimu menyenangkan ^_^"
	exit 0
}

# Fungsi untuk mengaktifkan BHAA
function aktifkan_bhaa(){

	status_aktif=()

	clear
	echo "-------------------------------------------------------------------------"
	echo "Bhaa - Aktifkan Bhaa                                                     "
	echo "-------------------------------------------------------------------------"
	echo "[*] Mengaktifkan modul 'auth_basic'..."
 
	sudo a2enmod auth_basic &> /dev/null
 
	if [[ $? -ne 0 ]]; then
		echo "[-] Modul 'auth_basic' gagal diaktifkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[+] Modul 'auth_basic' berhasil diaktifkan."
		status_aktif+=("Berhasil")
	fi

	echo "[*] Merestart layanan 'Apache2'..."
 
	sudo systemctl restart 
 
	if [[ $? -ne 0 ]]; then
		echo "[-] Layanan 'Apache2' gagal direstart."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[+] Layanan 'Apache2' berhasil direstart."
		status_aktif+=("Berhasil")
	fi

	echo "[*] Menyalin file '000-default.conf' ke '/etc/apache2/sites-enabled'..."

	cp 000-default.conf /etc/apache2/sites-enabled/

	if [[ $? -ne 0 ]]; then
	        echo "[-] File '000-default.conf' gagal disalin ke /etc/apache2/sites-enabled'."
		echo "-------------------------------------------------------------------------"
	        tekan_enter
		main
	else
		echo "[+] File '000-default.conf' berhasil disalin ke /etc/apache2/sites-enabled'."
		status_aktif+=("Berhasil")
	fi

	echo "[*] Menyalin file 'apache2.conf' ke '/etc/apache2'..."

	sudo cp apache2.conf /etc/apache2/

	if [[ $? -ne 0 ]]; then
	        echo "[-] File 'apache2.conf' gagal disalin ke /etc/apache2'."
		echo "-------------------------------------------------------------------------"
	        tekan_enter
		main
	else
		echo "[+] File 'apache2.conf' berhasil disalin ke '/etc/apache2'."
		status_aktif+=("Berhasil")
	fi

	echo "[*] Menyalin file '.htaccess' ke '/var/www/html'..."

	sudo cp .htaccess /var/www/html/

	if [[ $? -ne 0 ]]; then
	        echo "[-] File '.htaccess' gagal disalin ke /var/www/html'."
		echo "-------------------------------------------------------------------------"
	        tekan_enter
		main
	else
		echo "[+] File '.htaccess' berhasil disalin ke '/var/www/html'."
		status_aktif+=("Berhasil")
	fi


	echo "[*] Merestart layanan 'Apache2'..."

	sudo systemctl restart apache2

	if [[ $? -ne 0 ]]; then
	        echo "[-] Layanan 'Apache2' gagal direstart."
		echo "-------------------------------------------------------------------------"
	        tekan_enter
		main
	else
		echo "[+] Layanan 'Apache2' berhasil direstart."
		status_aktif+=("Berhasil")
	fi


	if [[ "${#status_aktif[@]}" -eq 6 ]]; then
		echo "[+] Bhaa berhasil dikatifkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[-] Bhaa gagal dinonaktifkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	fi
}

# Fungsi untuk memasukkan username
function masukkan_username(){

	clear

	if [[ "${pilih_menu}" == "3" ]]; then
		echo "-------------------------------------------------------------------------"
		echo "Bhaa - Buat User Baru                                                    "
		echo "-------------------------------------------------------------------------"
	elif [[ "${pilih_menu}" == "4" ]]; then
		echo "-------------------------------------------------------------------------"
		echo "Bhaa - Tambah User                                                       "
		echo "-------------------------------------------------------------------------"
	fi

	while true; do
		read -p "[#] Masukkan username (nama pengguna): " username
		if [[ -z "${username}" ]]; then
			echo "[-] Username tidak boleh kosong."
			continue
		fi
		break
	done
}

# Fungsi untuk memilih jenis enkripsi untu password
function pilih_jenis_enkripsi_password(){
		echo ""
		echo "Jenis Enkripsi yang Tersedia:"
		echo ""
		echo "[1] SHA-1 (Tidak aman)"
		echo "[2] MD5 (Tidak aman)"
		echo "[3] SHA-256 (Aman)"
		echo "[4] SHA-512 (Aman)"
		echo "[5] Bcrypt (Sangat aman)"
		echo ""
		while true; do
			read -p "[#] Pilih jenis enkripsi untuk passwordnya: " jenis_enkripsi
			if [[ "${jenis_enkripsi}" == "1" ]]; then
				opsi="-s"
				break
			elif [[ "${jenis_enkripsi}" == "2" ]]; then
				opsi="-m"
				break
			elif [[ "${jenis_enkripsi}" == "3" ]]; then
				opsi="-2"
				break
			elif [[ "${jenis_enkripsi}" == "4" ]]; then
				opsi="-5"
				break
			elif [[ "${jenis_enkripsi}" == "5" ]]; then
				opsi="-B"
				break
			else
				echo "[-] Jenis enkripsi tidak tersedia. Silahkan pilih kembali."
				continue
			fi
		done
}

# Fungsi untuk menambahkan user
function tambah_user(){
	echo "[*] Menambahkan user '${username}'..."
	echo ""
 
	htpasswd "${opsi}" /etc/apache2/.htpasswd "${username}"
 
	if [[ $? -ne 0 ]]; then
		echo ""
		echo "[-] User '${username}' gagal ditambahkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo ""
		echo "[+] User '${username}' berhasil ditambahkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	fi

}

# Fungsi untuk membuat user baru
function buat_user(){
	echo "[*] Membuat user baru '${username}'..."
	echo ""
 
	htpasswd -c "${opsi}" /etc/apache2/.htpasswd "${username}"

	if [[ $? -ne 0 ]]; then
		echo ""
		echo "[-] User baru '${username}' gagal ditambahkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo ""
		echo "[+] User baru '${username}' berhasil ditambahkan."
		tekan_enter
		main
	fi
}


# Fungsi untuk menampilkan user yang ada
function menampilkan_user(){

	clear

	if [[ "${pilih_menu}" == "2" ]]; then
		echo "-------------------------------------------------------------------------"
		echo "Bhaa - Menampilkan User                                                  "
		echo "-------------------------------------------------------------------------"
	elif [[ "${pilih_menu}" == "5" ]]; then
		echo "-------------------------------------------------------------------------"
		echo "Bhaa - Hapus User                                                        "
		echo "-------------------------------------------------------------------------"
	fi

        if [[ ! -f /etc/apache2/.htpasswd ]]; then 
                echo "[-] File '/etc/apache2/.htpasswd' tidak ditemukan."
                echo "-------------------------------------------------------------------------"
                tekan_enter
                main
        fi

	daftar_user=($(cat /etc/apache2/.htpasswd | cut -d ':' -f 1))
 
	echo "[*] Menampilkan seluruh user yang ada di file '/etc/apache2/.htpasswd'..."
 
	if [[ "${#daftar_user[@]}" -eq 0 ]]; then
		echo ""
		echo "Tidak ada user yang ditemukan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo ""
		echo "User yang ditemukan:"
		echo ""

		for u in "${daftar_user[@]}"; do
			echo "[+] ${u}"
		done
		if [[ "${pilih_menu}" == "2" ]]; then
			echo "-------------------------------------------------------------------------"
			tekan_enter
			main
		elif [[ "${pilih_menu}" == "5" ]]; then
			echo ""
		fi
	fi

}

# Fungsi untuk menghapus user
function hapus_user(){
	while true; do
		read -p "[#] Masukkan username yang akan dihapus: " user_d

		if [[ -z "${user_d}" ]]; then
			echo "[-] Username tidak boleh kosong."
			continue
		fi

		grep -q "^${user_d}:" /etc/apache2/.htpasswd
  
        	if [[ $? -ne 0 ]]; then
            		echo "[-] User '${user_d}' tidak ditemukan di file '/etc/apache2/.htpasswd'."
            		continue
        	fi

		while true; do
			read -p "[#] Apakah Anda yakin ingin menghapus user '${user_d}' [Y/n]: " konfirmasi
			if [[ "${konfirmasi}" == "y" || "${konfirmasi}" == "Y" ]]; then
				echo "[*] Menghapus user '${user_d}'..."

				sed -i "/^${user_d}:/d" /etc/apache2/.htpasswd

				if [[ $? -ne 0 ]]; then
					echo "[-] User '${user_d}' gagal dihapus."
					echo "-------------------------------------------------------------------------"
					tekan_enter
					main
				else
					echo "[+] User '${user_d}' berhasil dihapus."
					echo "-------------------------------------------------------------------------"
					tekan_enter
					main
				fi
				echo ""
			elif [[ "${konfirmasi}" == "n" || "${konfirmasi}" == "N" ]]; then
				echo "[-] User '${user_d}' tidak jadi dihapus."
				echo "-------------------------------------------------------------------------"
				tekan_enter
				main
			else
				echo "[-] Masukkan tidak valid. Harap masukkan 'Y/n'."
				continue
			fi
		done
	done
}

# Fungsi untuk menonaktifkan BHAA
function nonaktifkan_bhaa(){

	status_nonaktif=()

	clear

	echo "-------------------------------------------------------------------------"
	echo "Bhaa - Nonaktifkan Bhaa                                                  "
	echo "-------------------------------------------------------------------------"
	echo "[*] Menonaktifkan modul 'auth_basic'..."
 
	a2dismod auth_basic -f &> /dev/null
 
	if [[ $? -ne 0 ]]; then
		echo "[-] Modul 'auth_basic' gagal dinonaktifkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[+] Modul 'auth_basic' berhasil dinonaktifkan."
		status_nonaktif+=("Berhasil")
	fi
 
	echo "[*] Merestart layanan Apache2..."

	systemctl restart apache2
 
	if [[ $? -ne 0 ]]; then
		echo "[-] Layanan 'Apache2' gagal direstart."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[+] Layanan 'Apache2' berhasil direstart."
		status_nonaktif+=("Berhasil")
	fi
 
	echo "[*] Menyalin file 'disable-000-default.conf' ke '/etc/apache2/sites-enabled/000-default.conf'..."

	cp disable-000-default.conf /etc/apache2/sites-enabled/000-default.conf
 
	if [[ $? -ne 0 ]]; then
		echo "File 'disable-000-default.conf' gagal disalin ke '/etc/apache2/sites-enabled/000-default.conf'."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[+] File 'disable-000-default.conf' berhasil disalin ke '/etc/apache2/sites-enabled/000-default.conf'."
		status_nonaktif+=("Berhasil")
	fi

	echo "[*] Menyalin file 'disable-apache2.conf' ke '/etc/apache2/apache2.conf'..."

	cp disable-apache2.conf /etc/apache2/apache2.conf
 
	if [[ $? -ne 0 ]]; then
		echo "File 'disable-apache2.conf' gagal disalin ke '/etc/apache2/apache2.conf'."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[+] File 'disable-apache2.conf' berhasil disalin ke '/etc/apache2/apache2.conf'."
		status_nonaktif+=("Berhasil")
	fi


	echo "[*] Menyalin file 'disable-htaccess' ke '/var/www/html/.htaccess'..."

	cp disable-htaccess /var/www/html/.htaccess
 
	if [[ $? -ne 0 ]]; then
		echo "[-] File 'disable-htaccess' gagal disalin ke '/var/www/html/.htaccess'."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[+] File 'disable-htaccess' berhasil disalin ke '/var/www/html/.htaccess'."
		status_nonaktif+=("Berhasil")
	fi
 
	echo "[*] Merestart layanan 'Apache2'..."

	systemctl restart apache2
 
	if [[ $? -ne 0 ]]; then
		echo "[-] Layanan 'Apache2' gagal direstart."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[+] Layanan 'Apache2' berhasil direstart."
		status_nonaktif+=("Berhasil")
	fi

	if [[ "${#status_nonaktif[@]}" -eq 6 ]]; then
		echo "[+] Bhaa berhasil dinonaktifkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	else
		echo "[-] Bhaa gagal dinonaktifkan."
		echo "-------------------------------------------------------------------------"
		tekan_enter
		main
	fi
}

# Fungsi untuk menampilkan tentang program BHHA
function tentang(){
	clear
	echo "-------------------------------------------------------------------------"
	echo "Bhaa - Tentang BHHA                                                      "
	echo "-------------------------------------------------------------------------"
	echo "BHHA adalah program Bash sederhana yang dirancang untuk membuat          "
	echo "dan mengelola Basic HTTP Authentication Apache2 baik untuk               "
	echo "melihat user, membuat user baru, menambahkan user dan menghapus          "
	echo "user.                                                                    "
	echo "-------------------------------------------------------------------------"
	echo "Dibuat oleh Rofi (fixploit03)"
	echo "-------------------------------------------------------------------------"
	tekan_enter
	main
}

# Fungsi utama program (main)
function main(){
	clear
	echo "-------------------------------------------------------------------------"
	echo "BHAA - Basic HTTP Authentication Apache2                                 "
	echo "-------------------------------------------------------------------------"
	echo "Menu BHAA:                                                               "
	echo "-------------------------------------------------------------------------"
	echo "[0] Keluar                                                               "
	echo "[1] Aktifkan BHHA                                                        "
	echo "[2] Lihat User                                                           "
	echo "[3] Buat User Baru                                                       "
	echo "[4] Tambah User                                                          "
	echo "[5] Hapus User                                                           "
	echo "[6] Nonaktifkan BHHA                                                     "
	echo "[7] Tentang                                                              "
	echo "-------------------------------------------------------------------------"
	while true; do
		read -p "[#] Pilih menu: " pilih_menu
		if [[ "${pilih_menu}" == "0" ]]; then
			keluar
		elif [[ "${pilih_menu}" == "1" ]]; then
			aktifkan_bhaa
		elif [[ "${pilih_menu}" == "2" ]]; then
			menampilkan_user
		elif [[ "${pilih_menu}" == "3" ]]; then
			masukkan_username
			pilih_jenis_enkripsi_password
			buat_user
		elif [[ "${pilih_menu}" == "4" ]]; then
			masukkan_username
			pilih_jenis_enkripsi_password
			tambah_user
		elif [[ "${pilih_menu}" == "5" ]]; then
			menampilkan_user
			hapus_user
		elif [[ "${pilih_menu}" == "6" ]]; then
			nonaktifkan_bhaa
		elif [[ "${pilih_menu}" == "7" ]]; then
			tentang
		else
			echo "[-] Menu tidak tersedia. Silahkan pilih kembali."
			continue
		fi
	done
}

# Memanggil fungsi main
main

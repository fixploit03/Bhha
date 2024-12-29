#!/bin/bash
# [menu_utama_bhaa]
# Kelola Basic HTTP Authentication secara otomatis.

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

function aktifkan_bhha(){
	echo "[*] Mengaktifkan modul 'auth_basic'..."
	sleep 3
	sudo a2enmod auth_basic
	if [[ $? -ne 0 ]]; then
		echo ""
		echo "[-] Modul 'auth_basic' gagal diaktifkan."
		tekan_enter
		main
	else
		echo ""
		echo "[+] Modul 'auth_basic' berhasil diaktifkan."
	fi

	echo "[*] Merestart layanan 'Apache2'..."
	sleep 3
	sudo systemctl restart apache2
	if [[ $? -ne 0 ]]; then
		echo ""
		echo "[-] Layanan 'Apacahe2' gagal direstart."
		tekan_enter
		main
	else
		echo ""
		echo "[+] Layanan 'Apache2' berhasil direstart."
	fi

	echo "[*] Menyalin file '000-default.conf' ke '/etc/apache2/sites-enabled'..."
	sleep 3

	cp 000-default.conf /etc/apache2/sites-enabled/

	if [[ $? -ne 0 ]]; then
			echo ""
	        echo "[-] File '000-default.conf' gagal disalin ke /etc/apache2/sites-enabled'."
	        tekan_enter
			main
	else
		echo ""
		echo "[+] File '000-default.conf' berhasil disalin ke /etc/apache2/sites-enabled'."
	fi


	echo "[*] Merestart layanan Apache2..."
	sleep 3

	sudo systemctl restart apache2

	if [[ $? -ne 0 ]]; then
			echo ""
	        echo "[-] Layanan Apache2 gagal direstart."
	        tekan_enter
			main
	else
		echo ""
		echo "[+] Layanan Apache2 berhasil direstart."
	fi


	echo "[*] Menyalin file 'apache2.conf' ke '/etc/apache2'..."
	sleep 3

	sudo cp apache2.conf /etc/apache2/

	if [[ $? -ne 0 ]]; then
			echo ""
	        echo "[-] File 'apache2.conf' gagal disalin ke /etc/apache2'."
	        tekan_enter
			main
	else
		echo ""
		echo "[+] File 'apache2.conf' berhasil disalin ke '/etc/apache2'."
	fi



	echo "[*] Menyalin file '.htaccess' ke '/var/www/html'..."
	sleep 3

	sudo cp .htaccess /var/www/html/

	if [[ $? -ne 0 ]]; then
			echo ""
	        echo "[-] File '.htaccess' gagal disalin ke /var/www/html'."
	        tekan_enter
			main
	else
		echo ""
		echo "[+] File '.htaccess' berhasil disalin ke '/var/www/html'."
	fi


	echo "[*] Merestart layanan Apache2..."

	sudo systemctl restart apache2

	if [[ $? -ne 0 ]]; then
			echo ""
	        echo "[-] Layanan Apache2 gagal direstart."
	        tekan_enter
			main
	else
		echo ""
		echo "[+] Layanan Apache2 berhasil direstart."
		tekan_enter
		main
	fi

}

# Fungsi untuk memasukkan username
function masukkan_username(){
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
	sleep 3
	htpasswd "${opsi}" /etc/apache2/.htpasswd "${username}"
	if [[ $? -ne 0 ]]; then
		echo ""
		echo "[-] User '${username}' gagal ditambahkan."
		tekan_enter
		main
	else
		echo ""
		echo "[+] User '${username}' berhasil ditambahkan."
		tekan_enter
		main
	fi

}

# Fungsi untuk membuat user baru
function buat_user(){
	echo "[*] Membuat user baru '${username}'..."
	echo ""
	sleep 3
	htpasswd -c "${opsi}" /etc/apache2/.htpasswd "${username}"

	if [[ $? -ne 0 ]]; then
		echo ""
		echo "[-] User baru '${username}' gagal ditambahkan."
		tekan_enter
		main
	else
		echo ""
		echo "[+] User baru '${username}' berhasil ditambahkan."
		while true; do
			read -p "[#] Mau menambahkan user yang lain [Y/n]: " nanya
			if [[ "${nanya}" == "y" || "${nanya}" == "Y" ]]; then
				masukkan_username
				pilih_jenis_enkripsi_password
				tambah_user
			elif [[ "${nanya}" == "n" || "${nanya}" == "N" ]]; then
				tekan_enter
				main
			else
				echo "[-] Masukkan tidak valid. Harap masukkan 'Y/n'."
				continue
			fi
		done
	fi
}


# Fungsi untuk menampilkan user yang ada
function menampilkan_user(){
	daftar_user=($(cat /etc/apache2/.htpasswd | cut -d ':' -f 1))
	echo "[*] Menampilkan seluruh user yang ada di file '/etc/apache2/.htpasswd'..."
	sleep 3

	if [[ "${#daftar_user[@]}" -eq 0 ]]; then
		echo ""
		echo "Tidak ada user yang ditemukan."
		tekan_enter
		main
	else
		echo ""
		echo "User yang ditemukan:"
		echo ""

		for u in "${daftar_user[@]}"; do
			echo "[+] ${u}"
		done

		if [[ "${pilih_menu}" == "1" ]]; then
			tekan_enter
			main
		else
			echo ""
		fi
	fi

}

# Fungsi untuk menghapus user
function hapus_user(){
	while true; do
		read -p "[#] Masukkan username yang akan dihapus: " user_d

		if [[ ! "${daftar_user}" =~ "${user_d}" ]]; then
			echo "[-] User ${user_d} tidak ditemukan dalam file '/etc/apache2/.htpasswd'."
			continue
		fi
		echo "[*] Menghapus user '${user_d}'..."
		sleep 3

		sed -i "/${user_d}/d" /etc/apache2/.htpasswd

		if [[ $? -ne 0 ]]; then
			echo "[-] User '${user_d}' gagal dihapus."
		fi

		echo "[+] User '${user_d}' berhasil dihapus."
		tekan_enter
		main
	done
}

function nonaktifkan_bhha(){
	echo "[*] Menonaktifkan layanan 'auth_basic'..."
	echo ""
	sleep 3
	a2dismod auth_basic
	if [[ $? -ne 0 ]]; then
		echo ""
		echo "[-] Layanan 'auth_basic' gagal dinonaktifkan."
		tekan_enter
		main
	else
		echo ""
		echo "[+] Layanan 'auth_basic' berhasil dinonaktifkan."
	fi
	echo "[*] Merestart layanan Apache2..."
	echo ""
	sleep 3
	systemctl restart apache2
	if [[ $? -ne 0 ]]; then
		echo ""
		echo "[-] Layanan 'Apache2' gagal direstart."
		tekan_enter
		main
	else
		echo ""
		echo "[+] Layanan 'Apache2' berhasil direstart "
		tekan_enter
		main
	fi
}

# Fungsi untuk menampilkan tentang program BHHA
function tentang(){
	echo ""
	echo "Tentang BHHA"
	echo ""
	echo "BHHA adalah program Bash sederhana yang dirancang untuk membuat"
	echo "dan mengelola Basic HTTP Authentication baik untuk melihat user"
	echo ", membuat user baru, menambahkan user dan menghapus user."
	echo ""
	echo "Dibuat oleh Rofi (fixploit03)"
	tekan_enter
	main
}

# Fungsi utama program (main)
function main(){
	clear
	echo "----------------------------------------"
	echo "BHAA - Basic HTTP Authentication Apache2"
	echo "----------------------------------------"
	echo "Menu BHAA:"
	echo "----------------------------------------"
	echo "[0] Keluar"
	echo "[1] Aktifkan BHHA"
	echo "[2] Lihat User"
	echo "[3] Buat User Baru"
	echo "[4] Tambah User"
	echo "[5] Hapus User"
	echo "[6] Nonaktifkan BHHA"
	echo "[7] Tentang"
	echo "----------------------------------------"
	while true; do
		read -p "[#] Pilih menu: " pilih_menu
		if [[ "${pilih_menu}" == "0" ]]; then
			keluar
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
		elif [[ "${pilih_menu}" == "5" ]]; then
			tentang
		else
			echo "[-] Menu tidak tersedia. Silahkan pilih kembali."
			continue
		fi
	done
}

# Memanggil fungsi main
main
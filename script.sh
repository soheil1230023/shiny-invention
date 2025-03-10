#!/bin/sh

# تاخیر 30 ثانیه‌ای قبل از اجرای اسکریپت
sleep 30

# دانلود فایل لیست وب‌سایت‌ها از GitHub
curl -s https://raw.githubusercontent.com/hadikhan63/HADIKHAN/6bbf50414a6bc91f5964d1d5770dc1757f1f286f/List -o /tmp/website_list.txt

# استخراج URL‌ها از فایل و ساخت لیستی از آنها
domains=$(cat /tmp/website_list.txt | grep -oP "(?<=^http[s]?://)[^\"]+")

# فایل passwall2 در مسیر /etc/config/
config_file="/etc/config/passwall2"

# چک کردن اینکه آیا فایل passwall2 وجود دارد
if [ ! -f $config_file ]; then
    echo "فایل passwall2 پیدا نشد!"
    exit 1
fi

# استخراج بخش 'option domain_list' تا 'config shunt_rules'
start_line=$(grep -n "option domain_list" $config_file | cut -d: -f1)
end_line=$(grep -n "config shunt_rules" $config_file | cut -d: -f1)

if [ -z "$start_line" ] || [ -z "$end_line" ]; then
    echo "خطوط مورد نظر در فایل پیکربندی پیدا نشدند!"
    exit 1
fi

# استخراج بخش میان خطوط 'option domain_list' و 'config shunt_rules'
head -n $start_line $config_file > /tmp/passwall2_temp
echo "option domain_list" >> /tmp/passwall2_temp
for domain in $domains; do
    echo "    '$domain'" >> /tmp/passwall2_temp
done
echo "'" >> /tmp/passwall2_temp
tail -n +$end_line $config_file >> /tmp/passwall2_temp

# جایگزینی فایل اصلی با نسخه ویرایش شده
cp /tmp/passwall2_temp $config_file

# ریستارت سرویس passwall2 برای اعمال تغییرات
/etc/init.d/passwall2 restart

# پیغام موفقیت‌آمیز
echo "اسکریپت با موفقیت اجرا شد. فایل passwall2 ویرایش شد و سرویس ریستارت گردید."

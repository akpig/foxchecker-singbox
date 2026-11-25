# foxchecker-singbox

[English](../README.md) · [简体中文](../zh-cn/README.md) · [繁體中文](../zh-hant/README.md) · [日本語](../ja/README.md) · [Русский](../ru-ru/README.md) · [Türkçe](../tr-tr/README.md) · [Tiếng Việt](../vi-vn/README.md) · **العربية** · [فارسی](../fa-ir/README.md) · [اردو](../ur-pk/README.md)

يستخدم Foxchecker نواة sing-box لفحص عُقد الوكيل في روابط المشاركة والاشتراكات. يتضمن التقرير إمكانية الاتصال عبر HTTPS، وعنوان IP للدخول، وعنوان IP للخروج الفعلي، والبلد أو المنطقة بحسب GeoIP، ونتائج منفصلة لكل من UDP4 وUDP6. يستخدم البرنامج النصي صورة جاهزة ويتطلب تشغيل Docker. [صورة Docker Hub](https://hub.docker.com/r/akpig/foxchecker-singbox)

## البدء السريع

تحتاج إلى Bash وإمكانية الوصول إلى محرك Docker يشغّل حاويات Linux، ومجلد قابل للكتابة لحفظ التقارير. تستهدف الصورة منصة `linux/amd64`. يجب أن يدعم Docker على أجهزة ARM تشغيل حاويات amd64. يجب أيضًا أن يتمكن المحرك من الوصول إلى مجلد التقارير وملف الاشتراك المحلي على الجهاز المضيف.

### التشغيل مباشرة من GitHub

نفّذ الأوامر في المجلد الذي تريد حفظ التقرير فيه. تُنزّل الأوامر `singbox-checker.sh` من الفرع الافتراضي لمستودع GitHub. تُمرّر الوسائط التي تلي `bash -s --` إلى البرنامج النصي.

```bash
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- 'vmess://…'
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- -s 'https://sub.foxdetector.com/ar/top500/sing-box.json'
```

### تشغيل نسخة محلية

نفّذ الأوامر من مجلد المستودع واستبدل المدخلات التجريبية حسب الحاجة. لحفظ التقارير في مكان آخر، انتقل إلى المجلد المطلوب وشغّل البرنامج النصي باستخدام مساره المطلق.

#### فحص رابط مشاركة واحد

```bash
./singbox-checker.sh 'vmess://…'
```

صيغ الروابط المدعومة هي `vmess://`, `vless://`, `trojan://`, `ss://`, `hysteria2://` (`hy2://`), `tuic://`, `anytls://`. تعتمد وسائل النقل المتاحة على دعم sing-box لإعدادات العُقدة.

#### فحص اشتراك

```bash
./singbox-checker.sh -s 'https://sub.foxdetector.com/ar/top500/sing-box.json'
./singbox-checker.sh -s './sing-box.json' --format sing-box -c 8 --timeout 15s
```

يقبل الخيار `-s` عنوان HTTPS عامًا أو ملفًا محليًا. تُفسّر المسارات النسبية انطلاقًا من المجلد الحالي. يُكتشف التنسيق تلقائيًا، ويشمل Clash YAML بعُقد مضمّنة، أو قوائم روابط V2Ray بنص عادي أو بترميز Base64، أو sing-box JSON.

| الخيار | الغرض |
| --- | --- |
| `-s`, `--subscription` | تحديد عنوان الاشتراك أو الملف المحلي |
| `-c`, `--concurrent` | الحد الأقصى لفحوص الاشتراك المتزامنة. القيمة الافتراضية `16`. |
| `--format` | تنسيق الاشتراك. القيمة الافتراضية `auto`. يمكن تحديد `clash` أو `v2ray` أو sing-box. |
| `--timeout` | مهلة فحص كل عُقدة. القيمة الافتراضية `10s`، وتنطبق على الروابط الفردية والاشتراكات. |
| `-h`, `--help` | عرض المساعدة |

## قراءة النتائج

يكتب البرنامج النصي `result.json` في المجلد الحالي ويستبدله عند إنشاء تقرير جديد. يسجّل تقرير الرابط الواحد نتيجة العُقدة مباشرة، بينما يعرض تقرير الاشتراك النتائج في `results` بحسب ترتيب المدخلات. عند فشل الفحص، راجع `error.code` و`https.reason`. تشير قيمة `null` في حقل UDP إلى تعذّر تحديد النتيجة. راجع `udp4_reason` أو `udp6_reason` للتفاصيل.

يستخدم البرنامج النصي الصورة `akpig/foxchecker-singbox:latest`. يسحبها Docker إن لم تكن موجودة محليًا. يُزيل البرنامج الحاوية عند انتهاء الفحص أو انقطاعه. عند فشل الفحص، يعيد رمز خروج غير صفري ويسجّل سبب الفشل حين يمكن إنشاء تقرير. إذا تعذّر تشغيل Docker أو كان الأمر غير صالح، فقد يبقى ملف `result.json` السابق. راجع رمز الخروج ومخرجات الطرفية.

## بناء الصورة محليًا

ضع ملف Foxchecker التنفيذي لنظام Linux amd64 في المسار `foxchecker/foxchecker`، ثم نفّذ الأمر التالي من مجلد المستودع.

```bash
./build.sh
```

يحدّث برنامج البناء بيانات GeoIP ويتحقق منها ثم ينشئ الصورة المحلية `foxchecker-singbox:latest`. يستخدم برنامج الفحص صورة Docker Hub المشار إليها أعلاه. راجع [geoip/NOTICE](../geoip/NOTICE) لمعرفة مصدر بيانات GeoIP.

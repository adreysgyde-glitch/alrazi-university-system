# دليل قاعدة بيانات منصة الرازي — MySQL

## معلومات عامة

- اسم قاعدة البيانات: `alrazi_university`
- المحرك: MySQL 8.0+
- الترميز: `utf8mb4_unicode_ci`
- الملف: `database/alrazi_university.sql`
- التصميم: علائقي، يستخدم Primary Keys وForeign Keys وUnique Constraints وIndexes وViews.
- محتوى Seed: بيانات تجريبية بأسماء وعناوين ونطاقات بريدية محجوزة للاختبار، وليست سجلات جامعية حقيقية.

## الجداول الأساسية والعلاقات

### الهوية والصلاحيات

- `users`: حسابات الدخول، بريد فريد، هاش كلمة المرور وحالة الحساب.
- `roles`: تعريف الأدوار.
- `user_roles`: علاقة متعدد إلى متعدد بين المستخدمين والأدوار.

### الهيكل الأكاديمي

- `departments` ← ترتبط بها `programs` و`courses` و`instructors`.
- `programs` ← يرتبط بها الطالب من خلال `students.program_id`.
- `academic_terms` ← تمثل الفصول والسنوات الأكاديمية.
- `students` ← ملف الطالب والرقم الجامعي وحالة القيد.
- `instructors` ← ملف عضو هيئة التدريس والقسم.
- `courses` ← المقررات التابعة للأقسام.
- `course_prerequisites` ← علاقة مقرر بمتطلباته السابقة.
- `sections` ← شعبة لمقرر في فصل دراسي مع عضو هيئة تدريس.
- `classrooms` و`class_sessions` ← القاعات ومواعيد المحاضرات.
- `enrollments` ← تسجيل الطالب في شعبة؛ يمنع تكرار تسجيل الطالب في الشعبة نفسها.

### التقييم والحضور

- `assessments`: الاختبارات والمشاريع والأوزان والدرجات القصوى.
- `grades`: درجة تسجيل الطالب في عنصر تقييم محدد.
- `attendance_sessions`: جلسة الحضور في تاريخ معين للشعبة.
- `attendance_records`: حالة حضور كل طالب مسجل في الجلسة.

### المالية

- `invoices`: الفواتير والرسوم وتاريخ الاستحقاق.
- `payments`: دفعات مرتبطة بالفاتورة، ويمكن أن تحتوي الفاتورة على دفعات متعددة.
- `installment_plans` و`installment_payments`: خطط التقسيط والدفعات المجدولة.
- `scholarships`: تعريف المنح وأنواعها ونسبة تغطيتها.
- `scholarship_awards`: ربط المنحة بالطالب والفصل ومبلغ الدعم وحالة الاعتماد.

### الخدمات المساندة

- `library_books`, `book_copies`, `library_loans`: فهرس الكتب والنسخ والإعارات.
- `labs`, `lab_reservations`: المختبرات والحجوزات.
- `student_clubs`, `activities`, `activity_registrations`: الأندية والفعاليات والتسجيل.
- `dorm_buildings`, `dorm_rooms`, `dorm_assignments`: المباني والغرف والتسكين.
- `transport_routes`, `vehicles`, `transport_subscriptions`: خطوط النقل والمركبات والاشتراكات.
- `cafeteria_outlets`, `cafeteria_products`, `cafeteria_orders`, `cafeteria_order_items`: منافذ المقصف والمنتجات والطلبات.
- `parking_zones`, `parking_permits`: مناطق المواقف وتصاريح المركبات.
- `inventory_items`, `inventory_transactions`: المخازن والأصناف وحركات المخزون.
- `announcements`, `notifications`: الإعلانات والتنبيهات.
- `audit_logs`: سجل تدقيق للأحداث المهمة.

## العروض الجاهزة للتقارير (Views)

```sql
SELECT * FROM v_student_academic_summary;
SELECT * FROM v_course_enrollment_summary;
SELECT * FROM v_invoice_balances;
```

- `v_student_academic_summary`: الطالب وبرنامجه وقسمه وعدد مقرراته النشطة.
- `v_course_enrollment_summary`: الشعب وعدد الطلاب المسجلين مقابل السعة.
- `v_invoice_balances`: إجمالي الفاتورة والمدفوع والمتبقي.

## الاستيراد عبر phpMyAdmin

1. أنشئ نسخة احتياطية من قاعدة البيانات الحالية قبل الدمج مع أي تطبيق قائم.
2. افتح phpMyAdmin واختر Import.
3. حدد `alrazi_university.sql` ثم نفذ الاستيراد.
4. تحقق من ظهور قاعدة `alrazi_university` وجداولها.
5. نفذ استعلامات الـ Views أعلاه للتأكد من نجاح الإنشاء.

إذا كان لديك تطبيق موجود مسبقاً بقاعدة بيانات أخرى، لا تستورد الملف فوق بياناته مباشرة. راجع أسماء الجداول والمفاتيح أولاً، ثم انقل أو ادمج الجداول المطلوبة في بيئة تطوير منفصلة.

## ربطها بتطبيق آخر

استخدم Backend التطبيق للاتصال بـ MySQL عبر مكتبة موثوقة، ولا تتصل بقاعدة البيانات من المتصفح مباشرة. النمط العام:

`Browser UI → HTTPS API → Server-side validation & authorization → MySQL`

الـ API المقترحة:

| Method | Endpoint | المهمة |
|---|---|---|
| GET | `/api/students` | قائمة الطلاب |
| POST | `/api/students` | إنشاء ملف طالب |
| GET | `/api/students/:id` | تفاصيل طالب |
| PUT | `/api/students/:id` | تحديث طالب |
| GET | `/api/courses` | قائمة المقررات |
| GET | `/api/sections` | الشعب والفصول |
| POST | `/api/enrollments` | تسجيل طالب في شعبة |
| GET | `/api/grades/:studentId` | درجات الطالب |
| GET | `/api/invoices/:studentId` | الفواتير والأرصدة |
| GET | `/api/announcements` | الإعلانات المنشورة |

## ملاحظات أمان مهمة

1. لا تخزن كلمة المرور كنص صريح؛ استخدم Argon2id أو bcrypt في الخادم.
2. لا تعتبر `user_roles` مجرد عنصر واجهة؛ تحقق من الدور والصلاحية في كل طلب API.
3. استخدم Prepared Statements أو ORM مع معاملات مربوطة لتجنب SQL Injection.
4. لا تحفظ بيانات صحية أو مالية أو شخصية حقيقية في النسخة التجريبية أو مستودع GitHub.
5. استخدم HTTPS، وتحقق من المدخلات، وحدد معدل الطلبات، وفعّل سجل تدقيق.
6. أنشئ نسخاً احتياطية دورية واختبر الاستعادة.
7. راجع القوانين والسياسات الجامعية قبل تخزين أو معالجة بيانات الطلاب الحقيقية.

## حدود النموذج الحالي

الواجهة الأمامية الحالية لا تتصل بقاعدة البيانات من تلقاء نفسها. SQL هو مخطط قاعدة البيانات المستقل الجاهز للربط. يجب بناء API في تطبيقك أو خادم منفصل وربط وظائف الواجهة به قبل تفعيل البيانات المشتركة وتسجيل الدخول الفعلي.

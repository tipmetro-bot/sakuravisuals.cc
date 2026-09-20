-- sakuravisuals.cc | client-only visual menu
-- No remote code, HTTP loaders or server modifications. The MM2 tab listens to
-- Murder Mystery 2's own client events and, if allowed, makes the same
-- read-only GetPlayerData query the MM2 client makes; nothing changes gameplay.
-- Run on the client. gethui/GetObjects support depends on your environment.
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UIS = game:GetService('UserInputService')
local Lighting = game:GetService('Lighting')
local TweenService = game:GetService('TweenService')
local Debris = game:GetService('Debris')
local me = Players.LocalPlayer
assert(me, 'Run sakuravisuals on the client')
local env = (getgenv and getgenv()) or _G
if env.SakuraVisualsCleanup then pcall(env.SakuraVisualsCleanup) end
local alive, connections, effects = true, {}, {}
local function connect(signal, fn)
    local c = signal:Connect(fn); table.insert(connections, c); return c
end
local EnglishText={
    ["LOCAL VISUALS  /  только на твоём экране"]="LOCAL VISUALS  /  visible only to you",
    ["Персонаж"]="Character",
    ["ESP / друзья"]="ESP / friends",
    ["Мир / погода"]="World / weather",
    ["Шейдеры"]="Shaders",
    ["Цвета"]="Colors",
    ["Кастомный игрок"]="Custom player",
    ["Модельки"]="Models",
    ["Танцы"]="Dances",
    ["Юзер-ЧИТЕР"]="Player watch",
    ["Каталог"]="Catalog",
    ["Настройки"]="Settings",
    ["● ВКЛ"]="● ON",
    ["○ ВЫКЛ"]="○ OFF",
    ["Трейл и плащ: выбери себя или подтверждённого друга. Эффекты сохраняются после респавна."]="Trail and cape: select yourself or a confirmed friend. Effects are reapplied after respawn.",
    ["Эффекты для"]="Effects for",
    ["Я"]="Me",
    ["Игрок не подтверждён как друг."]="This player is not a confirmed friend.",
    ["Трейл"]="Trail",
    ["Плащ • 16 слоёв"]="Cape • 16 layers",
    ["Drawing API отсутствует"]="Drawing API is unavailable",
    ["Drawing mode недоступен: "]="Drawing mode unavailable: ",
    ["Шляпа: ассет 12417021356 недоступен в этом окружении."]="Hat: asset 12417021356 is unavailable in this environment.",
    ["Ассет шляпы не содержит 3D-деталей."]="The hat asset contains no 3D parts.",
    ["Прозрачная китайская шляпа • на себя"]="Transparent Chinese hat • yourself",
    ["Китайская шляпа • Drawing mode"]="Chinese hat • Drawing mode",
    ["Drawing mode: геометрический конус без текстур, поверх сцены. Это альтернативная отрисовка, не копия Toolbox-меша. Включи также саму шляпу."]="Drawing mode: a texture-free cone drawn over the scene, not a copy of the Toolbox mesh. Enable the hat as well.",
    ["Кольцо при прыжке • 3 секунды"]="Jump ring • 3 seconds",
    ["Список игроков проверяется через Roblox IsFriendsWith. ESP можно включить только подтверждённым друзьям."]="Players are checked using Roblox IsFriendsWith. Friend ESP is available only for confirmed friends.",
    ["Игроки"]="Players",
    ["Выбери игрока"]="Select a player",
    ["Дружба ещё проверяется."]="Friendship is still being checked.",
    ["Это не подтверждённый друг."]="This is not a confirmed friend.",
    ["ESP выбранного друга"]="ESP for selected friend",
    ["Сначала выбери подтверждённого друга."]="Select a confirmed friend first.",
    ["Target ESP • ник, аватар, уголки"]="Target ESP • name, avatar, corners",
    ["На ПК — наведи курсор на персонажа. На сенсорном устройстве — наведи центр экрана. Угловая 2D-рамка без сплошных сторон."]="Desktop: point at a character. Touch: aim at the center of the screen. Uses a corner-only 2D box.",
    ["♥ друг"]="♥ friend",
    ["не друг"]="not a friend",
    ["проверка…"]="checking…",
    ["нет данных"]="unknown",
    ["Обновить анализ друзей"]="Refresh friend check",
    ["Независимые цвета • палитра, RGB и HEX. Цвет трейла, плаща и Friend ESP применяется ко всем включённым получателям. Если на плаще картинка, цвет подкрашивает её; белый фон включается во вкладке «Персонаж»."]="Independent colors • palette, RGB and HEX. Trail, cape and Friend ESP colors apply to every enabled recipient. When the cape carries an image, the colour tints it; the white background is toggled in the Character tab.",
    ["Цвет всей шляпы: текстуры и старые материалы убираются, Union-детали перекрашиваются. Прозрачность настраивается во вкладке «Персонаж»."]="Whole-hat color removes textures and material overrides, and recolors unions. Adjust transparency under Character.",
    ["Применить HEX"]="Apply HEX",
    ["HEX: введи #FF97C1 или #F9C"]="HEX: enter #FF97C1 or #F9C",
    ["Китайская шляпа"]="Chinese hat",
    ["Target ESP • рамка и ник"]="Target ESP • box and name",
    ["Кастомный игрок • Highlight"]="Custom player • Highlight",
    ["Клон-гость • цвет тела"]="Guest clone • body color",
    ["Клон-гость • Highlight"]="Guest clone • Highlight",
    ["Погода, небо и время меняются только у тебя. Капли и снег появляются вокруг камеры, под крышей эмиссия останавливается."]="Weather, sky and time change only on your client. Rain and snow spawn around the camera; emission stops under a roof.",
    ["Время"]="Time",
    ["Исходное"]="Original",
    ["Утро"]="Morning",
    ["День"]="Day",
    ["Закат"]="Sunset",
    ["Ночь"]="Night",
    ["Сакура / розовое"]="Sakura / pink",
    ["Космос"]="Space",
    ["Скайбокс"]="Skybox",
    ["Исходный"]="Original",
    ["Ясное небо"]="Clear sky",
    ["Дождь • капли"]="Rain • drops",
    ["Зима • снег"]="Winter • snow",
    ["Туман"]="Fog",
    ["Прозрачный / лёгкий туман"]="Transparent / light fog",
    ["Свечение тумана"]="Fog glow",
    ["Это пресеты Roblox Lighting и постобработки, не внешние GPU-шейдеры. На низком качестве графики часть эффектов может быть незаметна."]="These are Roblox Lighting and post-processing presets, not external GPU shaders. Some effects may be hidden at low graphics quality.",
    ["Без пресета"]="No preset",
    ["Пресет"]="Preset",
    ["Меню: верхняя кнопка или RightShift. Размер автоматически подстраивается под экран. Друзей можно выбрать только среди игроков текущего сервера."]="Menu: top button or RightShift. Automatically fits your screen. Friends must be in the current server.",
    ["Удаление выключает эффекты, удаляет интерфейс и возвращает сохранённое освещение. Изменения Lighting другими скриптами игры могут перезаписывать пресеты."]="Removing the script stops effects and restores saved lighting. Other game scripts may overwrite lighting presets.",
    ["Удалить sakuravisuals / восстановить мир"]="Remove sakuravisuals / restore world",
    ["По умолчанию прозрачность 70%. Настрой её ниже: 0% — непрозрачный, 100% — невидимый. На 100% Highlight может исчезать."]="Default transparency: 70%. Adjust below: 0% is opaque, 100% is invisible. Highlight may disappear at 100%.",
    ["Кастомный игрок • прозрачность + Highlight"]="Custom player • transparency + Highlight",
    ["Введи число от "]="Enter a number from ",
    [" до "]=" to ",
    ["Прозрачность китайской шляпы"]="Chinese hat transparency",
    ["Китайская шляпа • чистый белый #FFFFFF"]="Chinese hat • pure white #FFFFFF",
    ["Прозрачность персонажа"]="Character transparency",
    ["Спинбот • только визуальный"]="Spinbot • visual only",
    ["Скорость вращения (°/сек)"]="Spin speed (°/sec)",
    ["Спинбот вращает только локальную копию или надетую модельку. Физический персонаж, управление и камера не вращаются."]="Spinbot rotates only a local copy or equipped model. Your physical character, controls and camera do not rotate.",
    ["Изменить цвет Highlight → Цвета"]="Change Highlight color → Colors",
    ["Цвета → «Кастомный игрок • Highlight». Работает после респавна. Обычные ESP и шляпа настраиваются независимо."]="Colors → Custom player • Highlight. Reapplied after respawn. Other ESP effects and the hat are independent.",
    ["Введи ID модели из Creator Store, нажми «Добавить», затем выбери карточку. Модель — статичная оболочка: следует за тобой, но без собственной анимации и скриптов."]="Enter a Creator Store model ID, click Add, then select its card. Models are static visual shells with no scripts or their own animation.",
    ["Asset ID модели"]="Model asset ID",
    ["Добавить"]="Add",
    ["Выбрано: нет модели"]="Selected: no model",
    ["● СНЯТЬ  •  "]="● REMOVE  •  ",
    ["ВЫБРАТЬ  •  "]="SELECT  •  ",
    ["Выбрано: "]="Selected: ",
    ["Снять модель / вернуть аватар"]="Remove model / restore avatar",
    ["Размер −"]="Size −",
    ["Размер +"]="Size +",
    ["Повернуть модель на 90°"]="Rotate model by 90°",
    ["Дождись окончания загрузки модели."]="Wait for the model to finish loading.",
    ["Введи числовой Asset ID модели из Creator Store."]="Enter a numeric Creator Store model asset ID.",
    ["Модель уже добавлена — нажми её карточку."]="This model is already added. Click its card.",
    ["Лимит: 8 моделей за запуск, чтобы не перегружать устройство."]="Limit: 8 models per run to reduce device load.",
    ["Загрузка…"]="Loading…",
    ["Модель"]="Model",
    ["Ассет недоступен / GetObjects не поддерживается"]="Asset unavailable / GetObjects unsupported",
    ["Слишком сложная модель: больше 400 деталей"]="Model is too complex: more than 400 parts",
    ["В этом ассете нет 3D-деталей"]="This asset contains no 3D parts",
    ["Неподходящие размеры модели"]="Unsupported model dimensions",
    ["Не удалось добавить: "]="Could not add: ",
    ["Модель добавлена. Нажми карточку, чтобы надеть."]="Model added. Click its card to equip it.",
    ["Анти-флинг • нет столкновений с игроками"]="Anti-fling • no player collisions",
    ["Анти-флинг: локальные NoCollisionConstraint между твоими деталями и деталями других игроков. Стены и пол остаются твёрдыми. Не защищает от скриптовых толчков, транспорта или серверной физики."]="Anti-fling uses local NoCollisionConstraints between your parts and other players. Floors and walls remain solid. It cannot prevent scripted pushes, vehicle effects or server physics.",
    ["Клон-гость"]="Guest clone",
    ["Задержка клона (мс)"]="Clone delay (ms)",
    ["Прозрачность клона"]="Clone transparency",
    ["Клон-гость • свой цвет тела"]="Guest clone • custom body color",
    ["Цвет тела / Highlight клона → Цвета"]="Clone body / Highlight color → Colors",
    ["Клон повторяет видимый танец и Tool с задержкой. Цвета тела и Highlight — независимые, во вкладке «Цвета». Выбор цвета тела включает его перекраску; выключатель возвращает исходный вид."]="The clone repeats the visible dance and Tool with a delay. Body and Highlight colors are independent. Selecting a body color enables recoloring; turn it off to restore the original look.",
    ["Одежда и аксессуары сохраняют свой цвет. При перекраске тела убираются его меш-текстуры. На 100% прозрачности Roblox может не показывать Highlight."]="Clothes and accessories keep their colors. Body recoloring removes mesh textures. Roblox may not display Highlight at 100% transparency.",
    ["Эмоции из магазина аватаров Roblox. Вставь ID или ссылку /catalog/… → «Добавить» → нажми карточку. Миниатюра — картинка из каталога, не видеопревью."]="Roblox Avatar Shop emotes. Paste an ID or /catalog/ link, click Add, then select a card. Thumbnails are catalog images, not video previews.",
    ["Танец виден только тебе и продолжается при ходьбе. Нужен R15 и доступ к анимации. Во время танца моделька-замена и визуальный спин временно скрыты."]="Dances are local and continue while walking. Requires R15 and animation access. Replacement models and visual spin are temporarily hidden during a dance.",
    ["ID эмоции / ссылка из магазина"]="Emote ID / Avatar Shop link",
    ["Экипированный Tool отображается в танцующей руке. Это визуальная копия предмета; настоящий Tool, его скрипты и управление остаются у персонажа."]="Equipped Tools are mirrored in the dancing hand. The actual Tool, its scripts and its controls remain on your character.",
    ["Танец не выбран."]="No dance selected.",
    ["Остановить танец / вернуть аватар"]="Stop dance / restore avatar",
    ["Скорость танца"]="Dance speed",
    ["● ИГРАЕТ  •  "]="● PLAYING  •  ",
    ["▶ ВЫБРАТЬ  •  "]="▶ SELECT  •  ",
    ["Танец остановлен."]="Dance stopped.",
    ["Не удалось создать локальную копию аватара"]="Could not create a local avatar copy",
    ["Аватар ещё не загрузился целиком. Повтори запуск танца."]="The avatar is not fully loaded yet. Try starting the dance again.",
    ["В аватаре нет Humanoid / HumanoidRootPart"]="Avatar is missing Humanoid / HumanoidRootPart",
    ["Нет корня у анимационного скелета"]="Animation rig has no root",
    ["Дождись появления персонажа."]="Wait for your character to spawn.",
    ["Эмоции магазина рассчитаны на R15. Сейчас у тебя R6."]="Avatar Shop emotes require R15. Your current rig is R6.",
    ["Загружаю: "]="Loading: ",
    ["После респавна ещё отсутствуют части тела. Нажми карточку позже."]="Some body parts are still missing after respawn. Try the card again later.",
    ["Анимация недоступна или не загрузилась. Попробуй другую эмоцию."]="Animation unavailable or failed to load. Try another emote.",
    ["Клип загружен, но скелет не получил позу. Проверь доступ к эмоции или попробуй другую."]="The clip loaded but the rig produced no pose. Check emote access or try another emote.",
    ["Ошибка: "]="Error: ",
    ["Анимация не найдена"]="Animation not found",
    ["Играет: "]="Playing: ",
    [" • ходьба не останавливает танец"]=" • walking does not stop the dance",
    ["Эмоция "]="Emote ",
    ["Подожди загрузки карточки."]="Wait for the card to finish loading.",
    ["Введи ID или ссылку roblox.com/catalog/… на эмоцию."]="Enter an emote ID or a roblox.com/catalog/ link.",
    ["Эта эмоция уже есть в карточках."]="This emote already has a card.",
    ["Лимит: 16 карточек эмоций за запуск."]="Limit: 16 emote cards per run.",
    ["Не удалось получить данные эмоции из магазина."]="Could not retrieve the emote's shop details.",
    ["Это не эмоция магазина аватаров. Нужен Emote Animation, не модель или одежда."]="This is not an Avatar Shop emote. Select an Emote Animation, not a model or clothing item.",
    ["  •  магазин аватаров"]="  •  Avatar Shop",
    ["Эмоция добавлена. Нажми карточку для запуска."]="Emote added. Click its card to play.",
    ["Анимационный скелет потерял корень"]="The animation rig lost its root",
    ["Танец остановлен из-за ошибки позы: "]="Dance stopped due to a pose error: ",
    ["Korblox загружен. Это локальная замена, без изменения аккаунта."]="Korblox loaded. This is a local replacement and does not change your account.",
    ["Korblox: правую ногу 139607718 загрузить не удалось. Настоящая нога не скрыта."]="Korblox: right leg 139607718 could not be loaded. Your real leg has not been hidden.",
    ["Локальная внешность: Headless и Korblox. Настоящие части тела не удаляются. Сохраняется после респавна, видна только тебе."]="Local appearance: Headless and Korblox. Real body parts are not deleted. Reapplied after respawn and visible only to you.",
    ["Хедлесс • скрыть голову и лицо"]="Headless • hide head and face",
    ["Корблокс • правая нога (R15)"]="Korblox • right leg (R15)",
    ["Korblox в этой версии требует R15."]="This Korblox implementation requires R15.",
    ["Korblox использует правую ногу Roblox 139607718. Если ассет недоступен, эффект не включится. Headless не удаляет волосы и головные аксессуары."]="Korblox uses Roblox right-leg asset 139607718. The effect stays off if it cannot load. Headless does not remove hair or head accessories.",
    ["ЮЗЕР-ЧИТЕР • НАБЛЮДЕНИЕ"]="PLAYER WATCH • OBSERVATIONS",
    ["Подозрения ≠ доказательства. Чужой код не виден."]="Suspicion is not proof. Other clients' code is not visible.",
    ["Наблюдение выключено."]="Observation disabled.",
    ["Перетаскивание — только при открытом меню"]="Drag only while the menu is open",
    ["Нельзя определить ThunderXHUB или загрузчик Luarmor на чужом клиенте. Их код не реплицируется. Этот HUD показывает только признаки необычного движения, а не факт читерства."]="You cannot detect ThunderXHUB or a Luarmor loader on another client. Their code is not replicated. This HUD flags unusual movement, not proven cheating.",
    ["HUD • подозрительные перемещения"]="HUD • suspicious movement",
    ["Собираю наблюдения…"]="Collecting observations…",
    ["Порог скорости (studs/сек)"]="Speed threshold (studs/sec)",
    ["Очистить список / начать заново"]="Clear list / restart observations",
    ["Наблюдения очищены."]="Observations cleared.",
    ["Условие: скорость по горизонтали выше порога не менее 3 секунд. Респавн, сидение и большие скачки позиции пропускаются. Способности игры и лаг всё равно могут дать ложную отметку."]="Flags horizontal speed above the threshold for at least 3 seconds. Respawns, sitting and large position jumps are ignored. Game abilities and lag can still cause false positives.",
    ["HUD можно двигать мышью или пальцем за заголовок, пока открыто меню. Имена появляются только у игроков, для которых клиент получил данные персонажа."]="Drag the HUD by its title with a mouse or finger while the menu is open. Only players whose character data reached your client can be observed.",
    ["… ещё "]="… more: ",
    ["@%s — подозрение\nСкорость %d > %d, держалась ≥3 с"]="@%s — flagged\nSpeed %d > %d, sustained ≥3 s",
    ["Подозрительных перемещений не отмечено.\n\nЭто не означает, что чужие скрипты отсутствуют."]="No suspicious movement observed.\n\nThis does not mean other clients have no scripts.",
    ["Все"]="All",
    ["Эмоции"]="Emotes",
    ["Аксессуары"]="Accessories",
    ["Одежда"]="Clothing",
    ["Бандлы"]="Bundles",
    ["Магазин аватаров Roblox: поиск, карточки и локальная примерка. Предметы не покупаются и не сохраняются на аккаунт. Для примерки нужен R15."]="Roblox Avatar Shop: search, cards and local try-on. Items are not purchased or saved to your account. Try-on requires R15.",
    ["Название, ID или ссылка Roblox"]="Name, ID or Roblox link",
    ["Найти"]="Search",
    ["Введи запрос или выбери категорию."]="Enter a search or choose a category.",
    ["Снять примерку / вернуть свой аватар"]="Remove try-on / restore your avatar",
    ["Следующая страница"]="Next page",
    ["Примерка снята."]="Try-on removed.",
    ["Модель каталога не содержит полного аватара."]="The catalog model does not contain a complete avatar.",
    ["Для примерки каталога нужен R15."]="Catalog try-on requires R15.",
    ["Примеряю: "]="Trying on: ",
    ["Roblox не вернул модель аватара."]="Roblox did not return an avatar model.",
    ["Примерка не удалась: "]="Try-on failed: ",
    ["Персонаж изменился"]="Character changed",
    ["Примерено: "]="Equipped locally: ",
    [" • только на твоём экране"]=" • visible only to you",
    ["Этот тип предмета пока нельзя примерить: "]="This item type is not supported for try-on yet: ",
    ["Загружаю предмет: "]="Loading item: ",
    ["В этом бандле нет поддерживаемых частей тела."]="This bundle has no supported body parts.",
    ["Эмоция отправлена в «Танцы»: "]="Emote sent to Dances: ",
    ["Бандл"]="Bundle",
    ["Предмет"]="Item",
    ["ПРИМЕРИТЬ"]="TRY ON",
    ["Найдено на странице: "]="Items on this page: ",
    ["Ничего не найдено. Измени запрос."]="No results. Try a different search.",
    ["Поиск в каталоге…"]="Searching the catalog…",
    ["Каталог недоступен: "]="Catalog unavailable: ",
    ["Поиск не удался. Можно попробовать точный ID или ссылку предмета."]="Search failed. Try an exact item ID or link instead.",
    ["Следующая страница недоступна: "]="Next page unavailable: ",
    ["Примерка остановлена: "]="Try-on stopped: ",
    ["Ошибка Drawing API: возвращаю 3D-шляпу."]="Drawing API error: switching back to the 3D hat.",
    ["sakuravisuals.cc готов • кнопка сверху / RightShift"]="sakuravisuals.cc ready • top button / RightShift",
    ["Язык интерфейса"]="Interface language",
    [" — подозрение\nСкорость "]=" — flagged\nSpeed ",
    [", держалась ≥3 с"]=", sustained ≥3 s",
    ["Переключение применяется сразу. Выбор сохраняется до закрытия сессии инжектора."]="Changes apply immediately. Your choice is kept for this injector session.",
    ["Введи username Roblox, а не Display Name. Игрок не обязан быть на сервере. Морф меняет только твою локальную внешность; имя и аккаунт остаются твоими."]="Enter a Roblox username, not a Display Name. The player does not need to be in your server. Morph only changes your local appearance, not your name or account.",
    ["Ник игрока / @username"]="Player username / @username",
    ["Morph Player • включить морф"]="Morph Player • enable morph",
    ["Морф выключен."]="Morph is off.",
    ["Игрок не выбран"]="No player selected",
    ["Ищу игрока: @"]="Looking up player: @",
    ["Загружаю аватар: @"]="Loading avatar: @",
    ["Морф активен: @"]="Morph active: @",
    ["Ник должен содержать 1–20 латинских букв, цифр или подчёркиваний."]="Use a username with 1–20 Latin letters, digits or underscores.",
    ["Пользователь не найден или Roblox не ответил. Проверь username."]="User not found or Roblox did not respond. Check the username.",
    ["Не удалось загрузить аватар игрока."]="Could not load the player avatar.",
    ["Для Morph Player нужен R15."]="Morph Player requires R15.",
    ["Предыдущий образ"]="Previous appearance",
    ["Морф выключен. Восстанавливаю предыдущий образ…"]="Morph is off. Restoring your previous appearance…",
    ["Предыдущий образ восстановлен."]="Previous appearance restored.",
    ["Не удалось восстановить примерку. Показан твой обычный аватар."]="Could not restore the try-on. Your normal avatar is shown.",
    ["Выключи Morph Player перед примеркой одежды или бандлов в каталоге. Эмоции можно использовать."]="Turn off Morph Player before trying on catalog clothing or bundles. Emotes remain available.",
    ["Выключатель возвращает предыдущую примерку или твой аватар. Измени ник и нажми Enter, чтобы сменить морф. Работает с R15 и восстанавливается после респавна."]="Turning morph off restores your previous try-on or your avatar. Change the username and press Enter to switch morphs. Requires R15 and is reapplied after respawn.",
    ["Ошибка морфа: "]="Morph error: ",
    ["Анимации морфа включаются автоматически: ожидание, ходьба, бег и прыжок. Это движения морфа, а не обязательно анимационный пак владельца профиля."]="Morph animations are automatic: idle, walking, running and jumping. They are not necessarily the profile owner's animation pack.",
    ["Анимации: ожидание морфа."]="Animations: waiting for a morph.",
    ["Анимации: стандартные R15 • "]="Animations: standard R15 • ",
    ["Анимации: базовое движение без загрузки • "]="Animations: built-in procedural motion • ",
    ["Эмоция не воспроизвелась на морфе; используются базовые движения."]="The emote did not play on the morph; basic movement is being used.",
    ["Анимации: эмоция."]="Animations: emote.",
    ["ожидание"]="idle",
    ["ходьба"]="walk",
    ["бег"]="run",
    ["прыжок"]="jump",
    ["падение"]="fall",
    ["лазание"]="climb",
    ["плавание"]="swim",
    ["сидение"]="sit",
}
EnglishText['↕ Прокрутка вкладок']='↕ Scroll tabs'
EnglishText['Погода везде • не проверять крышу']='Weather everywhere • skip roof check'
EnglishText['Вид трейла • цвет берётся из вкладки «Цвета»']='Trail style • colour comes from the Colours tab'
EnglishText['Линия']='Line'
EnglishText['Лепестки']='Petals'
EnglishText['Искры']='Sparks'
EnglishText['Орбы']='Orbs'
EnglishText['Дым']='Smoke'
EnglishText['Огонь']='Fire'
EnglishText['Вид трейла: ']='Trail style: '
EnglishText['Только для Murder Mystery 2. Всё локально: волна не наносит урона, подсветка и таймер видны только тебе. Начало раунда и роли берутся из событий игры (RoundStart, RoundEndFade, UpdatePlayerData), при необходимости — из GetPlayerData и по ножу/пистолету в руках.']='Murder Mystery 2 only. Everything is local: the wave deals no damage, the flash and timer are visible only to you. Round start and roles come from the game events (RoundStart, RoundEndFade, UpdatePlayerData), falling back to GetPlayerData and the knife/gun in hand.'
EnglishText['MM2: ожидание…']='MM2: waiting…'
EnglishText['MM2: найдено • ']='MM2: found • '
EnglishText['MM2: игра не похожа на Murder Mystery 2 (события не найдены)']='MM2: this game does not look like Murder Mystery 2 (events not found)'
EnglishText['MM2: раунд идёт']='MM2: round in progress'
EnglishText['MM2: тестовый запуск']='MM2: test run'
EnglishText['MM2: раунд завершён']='MM2: round over'
EnglishText['время вышло']='time is up'
EnglishText['сброс']='reset'
EnglishText['MM2 • взрыв-волна на старте раунда (без урона)']='MM2 • shockwave at round start (no damage)'
EnglishText['MM2 • подсветка мардера и шерифа на старте']='MM2 • flash murderer and sheriff at round start'
EnglishText['MM2 • таймер раунда']='MM2 • round timer'
EnglishText['MM2 • запрашивать роли через GetPlayerData']='MM2 • query roles via GetPlayerData'
EnglishText['Радиус волны']='Wave radius'
EnglishText['Длительность раунда']='Round length'
EnglishText['Подсветка держится']='Flash hold time'
EnglishText['Тест сейчас: волна + подсветка + таймер']='Test now: wave + flash + timer'
EnglishText['Сбросить таймер']='Reset timer'
EnglishText['Мардер']='Murderer'
EnglishText['Шериф']='Sheriff'
EnglishText['MM2 • волна']='MM2 • wave'
EnglishText['MM2 • мардер']='MM2 • murderer'
EnglishText['MM2 • шериф']='MM2 • sheriff'
EnglishText['Таймер: 3:00 по умолчанию (раунд MM2), при наличии подхватывает таймер самой игры. Подсветка: держится указанное время и плавно гаснет за 0.6 с.']='Timer: 3:00 by default (an MM2 round) and snaps to the game timer when found. Flash: holds for the chosen time, then fades out over 0.6 s.'
EnglishText['Картинка на плащ • ID картинки (декаль или ссылка)']='Cape image • image ID (decal or link)'
EnglishText['Плащ с картинкой: включи «Плащ • 16 слоёв», вставь ID картинки и нажми «Поставить картинку». Картинка висит на поверхности плаща, повторяет его изгиб, а 16 слоёв остаются цветной рамкой. Всё локально — другие игроки картинку не видят.']='Cape with an image: turn on "Cape • 16 layers", paste an image ID and press "Set image". The picture hangs on the cape surface and bends with it while the 16 layers stay as a coloured frame. Everything is local — other players do not see it.'
EnglishText['ID или ссылка: подойдёт ID декали, картинки Roblox или ссылка вида roblox.com/catalog/…. Прозрачные места картинки показывают цвет плаща, «белый фон» убирает подкраску.']='ID or link: a Roblox decal/image ID or a link such as roblox.com/catalog/… works. Transparent parts of the picture show the cape colour; "white background" removes the tint.'
EnglishText['Высота картинки']='Image height'
EnglishText['Плащ • картинка: белый фон (без подкраски)']='Cape • image: white background (no tint)'
EnglishText['Прозрачность плаща']='Cape transparency'
EnglishText['Поставить картинку']='Set image'
EnglishText['Убрать картинку']='Remove image'
EnglishText['ID картинки / ссылка (декаль Roblox)']='Image ID / link (Roblox decal)'
EnglishText['Картинка: не задана']='Image: none'
EnglishText['Картинка: ID ']='Image: ID '
EnglishText['Введи ID картинки или ссылку на декаль Roblox.']='Enter an image ID or a Roblox decal link.'
EnglishText['Эта картинка уже стоит на плаще.']='This image is already on the cape.'
EnglishText['Это не картинка/декаль Roblox — нужен ID картинки.']='This is not a Roblox image/decal — an image ID is required.'
EnglishText['Магазин не ответил — ставлю картинку как есть.']='The marketplace did not answer — setting the image as it is.'
EnglishText['Картинка поставлена на плащ.']='Image set on the cape.'
EnglishText['Картинка снята с плаща.']='Image removed from the cape.'
EnglishText['Проверяю…']='Checking…'
EnglishText['Плащ выключен: включи «Плащ • 16 слоёв», чтобы картинка появилась.']='The cape is off: turn on "Cape • 16 layers" to make the image appear.'
EnglishText['Проверка функций: нажми кнопку ниже — отчёт появится здесь и в консоли (print).']='Self-check: press the button below — the report appears here and in the console (print).'
EnglishText['Проверка функций • что загружено']='Self-check • what loaded'
EnglishText['Отчёт готов: список ниже и в консоли (print).']='Report ready: see the list below and the console (print).'
EnglishText['Картинка на плащ • вставь ID и нажми «Поставить картинку»']='Cape image • paste an ID and press "Set image"'
EnglishText['MM2 • подсветить пистолет, когда шериф погиб']='MM2 • highlight the gun when the sheriff dies'
EnglishText['Пистолет держится']='Gun hold time'
EnglishText['Пистолет гаснет']='Gun fade time'
EnglishText['Пистолет шерифа: когда шериф погибает, пистолет падает на землю — он подсвечивается 3 секунды, рядом идёт отсчёт, потом плавно гаснет. Работает только во время раунда MM2 и только если пистолет виден клиенту.']='Sheriff gun: when the sheriff dies the pistol drops on the ground — it is highlighted for 3 seconds with a countdown next to it, then fades out. Works only during an MM2 round and only if the pistol is visible to your client.'
EnglishText['Пистолет шерифа • шериф погиб']='Sheriff gun • sheriff died'
EnglishText['MM2: шериф погиб • ищу пистолет']='MM2: sheriff died • looking for the gun'
EnglishText['MM2: пистолет шерифа подсвечен']='MM2: sheriff gun highlighted'
EnglishText['MM2 • пистолет шерифа']='MM2 • sheriff gun'
EnglishText['сек']='sec'
EnglishText['Config • конфиги меню. У каждого конфига постоянный ID вида sv-123456: по нему конфиг находится, изменить ID нельзя. Название можно любое — придумай своё.']='Config • menu configs. Every config has a permanent ID such as sv-123456: that is how it is found, and the ID cannot be changed. The name is yours — pick any.'
EnglishText['Что сохраняется: все тумблеры и слайдеры, цвета (включая MM2), вид трейла, картинка на плащ и ник морфа. Конфигов может быть сколько угодно: например «MM2», «красиво», «лёгкий для телефона» — и переключение одним нажатием.']='What is saved: every toggle and slider, the colours (MM2 included), the trail style, the cape image and the morph username. You can keep as many configs as you like — for example "MM2", "pretty", "light for phone" — and switch between them in one click.'
EnglishText['Зачем это нужно: вернуть свои настройки после перезахода (галочка автозагрузки), безопасно экспериментировать — сохранил и вернул, и передать набор другому игроку. Конфиги лежат у тебя на устройстве в файле sakuravisuals_configs.json, поэтому ID сам по себе чужой конфиг не откроет: чтобы поделиться, скопируй экспорт-строку.']='Why it helps: get your settings back after rejoining (autoload tick), experiment safely — save then restore, and hand a setup to someone else. Configs live on your own device in sakuravisuals_configs.json, so an ID alone cannot open somebody else config: to share one, copy the export string.'
EnglishText['ID конфига, например sv-123456']='Config ID, for example sv-123456'
EnglishText['Название конфига (любое)']='Config name (anything)'
EnglishText['Добавить по ID']='Add by ID'
EnglishText['Новый ID']='New ID'
EnglishText['Переименовать']='Rename'
EnglishText['Сохранить настройки']='Save settings'
EnglishText['Загрузить выбранный']='Load selected'
EnglishText['Удалить конфиг']='Delete config'
EnglishText['Копировать ID']='Copy ID'
EnglishText['Экспорт в буфер']='Export to clipboard'
EnglishText['Импорт из буфера']='Import from clipboard'
EnglishText['Выключить всё']='Turn everything off'
EnglishText['Config • загружать выбранный конфиг при запуске']='Config • load the selected config on start'
EnglishText['Конфигов нет.']='No configs yet.'
EnglishText['Выбран: ']='Selected: '
EnglishText[' • конфигов: ']=' • configs: '
EnglishText['Конфигов: ']='Configs: '
EnglishText[' • выбери конфиг по ID или создай новый']=' • pick a config by ID or create a new one'
EnglishText['Сначала выбери конфиг по ID.']='Pick a config by ID first.'
EnglishText['ID должен быть вида sv-123456: латиница sv, дефис и цифры.']='The ID must look like sv-123456: latin letters sv, a dash and digits.'
EnglishText['Конфиг найден: ']='Config found: '
EnglishText['Конфиг создан: ']='Config created: '
EnglishText[' • сохрани в него настройки']=' • save your settings into it'
EnglishText['Новый ID: ']='New ID: '
EnglishText[' • имя можно поменять, ID останется таким навсегда']=' • the name can change, the ID stays forever'
EnglishText['Название не может быть пустым — ID остаётся прежним.']='The name cannot be empty — the ID stays as it is.'
EnglishText['Название сохранено. ID конфига не меняется: ']='Name saved. The config ID never changes: '
EnglishText['Сохранено настроек: ']='Settings saved: '
EnglishText[' • конфиг ']=' • config '
EnglishText['Нажми ещё раз, чтобы удалить конфиг ']='Press again to delete the config '
EnglishText['Конфиг удалён: ']='Config deleted: '
EnglishText['Буфер обмена недоступен: ID конфига — ']='Clipboard is unavailable: the config ID is '
EnglishText['Буфер обмена недоступен в этом исполнителе.']='The clipboard is unavailable in this executor.'
EnglishText['ID скопирован: ']='ID copied: '
EnglishText['Не удалось собрать конфиг для экспорта.']='Could not assemble the config for export.'
EnglishText['Буфер обмена недоступен — экспорт некуда положить.']='Clipboard is unavailable — nowhere to put the export.'
EnglishText['Экспорт конфига скопирован: ']='Config export copied: '
EnglishText[' • передай строку тому, кому нужен конфиг']=' • hand the string to whoever needs the config'
EnglishText['В буфере нет данных конфига.']='There is no config data in the clipboard.'
EnglishText['Импорт: в буфере не конфиг sakuravisuals.']='Import: the clipboard does not hold a sakuravisuals config.'
EnglishText['Импорт: конфиг ']='Import: config '
EnglishText[' добавлен']=' added'
EnglishText['Выключено функций: ']='Features switched off: '
EnglishText['Применено: ']='Applied: '
EnglishText[' • пропущено: ']=' • skipped: '
EnglishText['Конфиг при запуске: ']='Config on start: '
EnglishText[' • настроек: ']=' • settings: '
EnglishText['Не удалось записать файл конфигов — нет доступа к файлам.']='Could not write the config file — no file access.'
EnglishText['Файл конфигов повреждён — начинаю с пустого списка.']='The config file is damaged — starting with an empty list.'
EnglishText['Погода: выключена']='Weather: off'
EnglishText['Погода: идёт']='Weather: active'
EnglishText['Погода: пауза под крышей. Если крыши нет — включи «Погода везде».']='Weather: paused under a roof. If there is no roof, enable "Weather everywhere".'
EnglishText['Дождь и снег: несколько эмиттеров вокруг камеры, до 400 частиц/с на эмиттер (на телефоне меньше). Лучше всего видно на графике 5+.']='Rain and snow: several emitters around the camera, up to 400 particles/s each (fewer on phones). Best visible at graphics quality 5+.'
local interfaceLanguage=env.SakuraVisualLanguage=='en' and 'en' or 'ru'
local localizedObjects=setmetatable({},{__mode='k'})
local translationOrder={}
for source in pairs(EnglishText) do table.insert(translationOrder,source) end
table.sort(translationOrder,function(a,b) return #a>#b end)
local function translate(value)
    if interfaceLanguage~='en' then return value end
    if EnglishText[value] then return EnglishText[value] end
    local result=value
    local function wordByte(byte) return byte and (byte>=128 or byte>=48 and byte<=57 or byte>=65 and byte<=90 or byte>=97 and byte<=122 or byte==95) end
    for _,source in ipairs(translationOrder) do
        local pos=1
        while true do
            local a,b=string.find(result,source,pos,true)
            if not a then break end
            local single=not source:find('%s')
            if single and (wordByte(result:byte(a-1)) or wordByte(result:byte(b+1))) then pos=b+1
            else
                local replacement=EnglishText[source]
                result=result:sub(1,a-1)..replacement..result:sub(b+1)
                pos=a+#replacement
            end
        end
    end
    return result
end
local function applyLocalized(object,state)
    for property,record in pairs(state) do
        local rendered=object:GetAttribute('SakuraNoTranslate') and record.raw or translate(record.raw)
        record.shown=rendered
        if object[property]~=rendered then object[property]=rendered end
    end
end
local function localizeObject(object)
    local properties={}
    if object:IsA('TextLabel') or object:IsA('TextButton') then table.insert(properties,'Text') end
    -- Never translate what users type into inputs, including names/IDs/HEX.
    if object:IsA('TextBox') then table.insert(properties,'PlaceholderText') end
    if #properties==0 then return end
    local state={}; localizedObjects[object]=state
    for _,property in ipairs(properties) do
        state[property]={raw=object[property],shown=object[property]}
        connect(object:GetPropertyChangedSignal(property),function()
            local record=state[property]
            if object[property]==record.shown then return end
            record.raw=object[property]; applyLocalized(object,state)
        end)
    end
    connect(object:GetAttributeChangedSignal('SakuraNoTranslate'),function() applyLocalized(object,state) end)
    applyLocalized(object,state)
end
local function setInterfaceLanguage(language)
    interfaceLanguage=language=='en' and 'en' or 'ru'; env.SakuraVisualLanguage=interfaceLanguage
    for object,state in pairs(localizedObjects) do pcall(applyLocalized,object,state) end
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    localizeObject(o)
    o.Parent = parent; return o
end
local root = new('Folder', {Name='SakuraVisuals_Local'}, workspace)
local gui = new('ScreenGui', {Name='SakuraVisuals', ResetOnSpawn=false, IgnoreGuiInset=false, DisplayOrder=90, ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
local ok = pcall(function() gui.Parent = gethui and gethui() or game:GetService('CoreGui') end)
if not ok or not gui.Parent then gui.Parent = me:WaitForChild('PlayerGui') end
local pink = Color3.fromRGB(255,151,193)
local colors={hat=Color3.new(1,1,1),trail=pink,cape=pink,esp=pink,target=pink,mm2Wave=pink,mm2Murderer=Color3.fromRGB(255,64,64),mm2Sheriff=Color3.fromRGB(80,140,255),mm2Gun=Color3.fromRGB(255,205,80)}
local customHatColor=true
local hatTransparency=.55
colors.custom=pink
colors.guestSkin=Color3.new(1,1,1)
colors.guestHighlight=pink
local danceRig=nil
local catalogRig=nil
local catalogToolMirrors={}
local catalogPlayEmote,catalogDanceSource
local danceToolMirrors={}
local guestVisualModel=nil
local appearanceOriginals={}
local respawnHooks={}
local guestColorChanged
local customColorChanged,customCleanup
local mm2ColorChanged
local function shade(c) return c:Lerp(Color3.new(0,0,0),.55) end
local function tintHat(model)
    if not model or not customHatColor then return end
    local c=colors.hat
    -- Each write is isolated: a locked property must not stop the remaining
    -- parts from being recolored. SurfaceAppearance is removed FIRST.
    local function write(o,k,v)
        local ok,err=pcall(function() o[k]=v end)
        if not ok then warn('[Sakura hat] '..o.ClassName..'.'..k..': '..tostring(err)) end
    end
    for _,o in ipairs(model:GetDescendants()) do
        if o:IsA('SurfaceAppearance') or o:IsA('Decal') or o:IsA('Texture')
            or o:IsA('SurfaceGui') or o:IsA('BillboardGui')
            or o:IsA('Highlight') or o:IsA('Fire') or o:IsA('Smoke')
            or o:IsA('Sparkles') then
            o:Destroy()
        end
    end
    for _,o in ipairs(model:GetDescendants()) do
        if o:IsA('BasePart') then
            -- CSG unions otherwise retain their original per-face colors.
            if o:IsA('PartOperation') then write(o,'UsePartColor',true) end
            if o:IsA('MeshPart') then write(o,'TextureID','') end
            write(o,'MaterialVariant','')
            write(o,'Material',Enum.Material.SmoothPlastic)
            write(o,'Reflectance',0)
            write(o,'Color',c)
            write(o,'Transparency',hatTransparency)
            write(o,'LocalTransparencyModifier',0)
            write(o,'CastShadow',false)
        elseif o:IsA('SpecialMesh') then
            write(o,'TextureId','')
            -- With no texture the parent BasePart supplies the chosen color.
            write(o,'VertexColor',Vector3.new(1,1,1))
        elseif o:IsA('DataModelMesh') then
            write(o,'VertexColor',Vector3.new(1,1,1))
        elseif o:IsA('ParticleEmitter') or o:IsA('Trail') or o:IsA('Beam') then
            write(o,'Enabled',false)
            if o:IsA('ParticleEmitter') or o:IsA('Trail') then pcall(function() o:Clear() end) end
        elseif o:IsA('Light') then
            write(o,'Enabled',false)
        end
    end
end

local muted = Color3.fromRGB(175,168,192)
local function round(o, radius) new('UICorner',{CornerRadius=UDim.new(0,radius or 10)},o) end
local function text(parent, value, size, pos, dims)
    return new('TextLabel',{BackgroundTransparency=1,Text=value,TextColor3=Color3.fromRGB(239,231,247),Font=Enum.Font.Gotham,TextSize=size or 13,TextXAlignment=Enum.TextXAlignment.Left,Position=pos or UDim2.new(),Size=dims or UDim2.new(1,0,0,24)},parent)
end
local function button(parent, title, dims, pos)
    local b = new('TextButton',{Text=title,Size=dims or UDim2.new(1,0,0,36),Position=pos or UDim2.new(),BackgroundColor3=Color3.fromRGB(43,35,54),TextColor3=Color3.fromRGB(244,234,249),TextSize=13,Font=Enum.Font.GothamMedium,AutoButtonColor=true,BorderSizePixel=0},parent)
    round(b,9); return b
end
local launcher=button(gui,'✿  sakuravisuals.cc',UDim2.fromOffset(244,37),UDim2.new(.5,-122,0,8))
local window=new('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.52),Size=UDim2.fromOffset(650,490),BackgroundColor3=Color3.fromRGB(22,18,29),BorderSizePixel=0},gui)
round(window,16)
new('UIStroke',{Color=pink,Transparency=.6,Thickness=1},window)
-- Load checkpoints. If any executor makes a feature fail, this small label
-- inside the menu shows how far the script got instead of silently losing
-- tabs; SakuraVisualsReport() prints the same list plus what the executor
-- supports, and the "Проверка функций" button in Settings shows it in the menu.
local loadState={reached={},last='старт'}
local loadLabel=new('TextLabel',{Name='SakuraLoad',BackgroundTransparency=1,Text='загрузка: старт',TextColor3=muted,Font=Enum.Font.Code,TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Position=UDim2.new(0,14,1,-30),Size=UDim2.new(1,-28,0,20),ZIndex=60},window)
loadLabel:SetAttribute('SakuraNoTranslate',true)
local function checkpoint(name)
    loadState.last=name
    table.insert(loadState.reached,name)
    loadLabel.Text='загрузка: '..name
    pcall(print,'[sakuravisuals] '..name)
end
loadState.report=function()
    local lines={'sakuravisuals.cc • проверка функций',
        'этапов пройдено: '..#loadState.reached,
        'остановилось на: '..loadState.last,
        'вкладок меню: 14',
        'элементов в меню: '..#gui:GetDescendants()}
    local function cap(name,fn)
        local ok=pcall(fn)
        table.insert(lines,name..(ok and ' ✓' or ' ✗'))
    end
    cap('task.spawn',function() assert(task and task.spawn) end)
    cap('task.delay',function() assert(task and task.delay) end)
    cap('getgenv',function() assert(getgenv) end)
    cap('gethui',function() assert(gethui) end)
    cap('Drawing API',function() assert(Drawing and Drawing.new) end)
    cap('protect_gui / cloneref',function() assert(gethui or (syn and (syn.protect_gui or syn.cloneref))) end)
    cap('MarketplaceService',function() assert(game:GetService('MarketplaceService')) end)
    cap('AvatarEditorService',function() assert(game:GetService('AvatarEditorService')) end)
    cap('HumanoidDescription',function() assert(Players.GetHumanoidDescriptionFromUserId) end)
    cap('R15 аватар',function()
        local humanoid=me.Character and me.Character:FindFirstChildOfClass('Humanoid')
        assert(humanoid and humanoid.RigType==Enum.HumanoidRigType.R15)
    end)
    local report=table.concat(lines,'\n')
    pcall(print,'[sakuravisuals]\n'..report)
    return report
end
env.SakuraVisualsReport=loadState.report
checkpoint('меню')
checkpoint('фон')
-- Animated black & white constellation background: moving dots with
-- connecting lines (monochrome only). Runs only while the menu is visible.
;(function()
    window.BackgroundColor3 = Color3.new(0,0,0)
    local bg = new('Frame',{BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Size=UDim2.new(1,0,1,0),Position=UDim2.new(),ZIndex=1,ClipsDescendants=true},window)
    local WHITE = Color3.new(1,1,1)
    local DOT_COUNT = 28
    local LINE_POOL = 70
    local LINK_DIST = 125
    local SPEED_MIN, SPEED_MAX = 34, 78
    local dots = {}
    for i=1,DOT_COUNT do
        local d = new('Frame',{BackgroundColor3=WHITE,BorderSizePixel=0,AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(6,6),BackgroundTransparency=.12,ZIndex=2},bg)
        round(d,3)
        dots[i]={node=d,x=0,y=0,vx=0,vy=0}
    end
    local lines = {}
    for i=1,LINE_POOL do
        lines[i]=new('Frame',{BackgroundColor3=WHITE,BorderSizePixel=0,AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(0,1),BackgroundTransparency=1,Visible=false,ZIndex=1},bg)
    end
    local lastW,lastH = 0,0
    local function seed(w,h)
        for _,d in ipairs(dots) do
            d.x = math.random()*math.max(1,w-8)+4
            d.y = math.random()*math.max(1,h-8)+4
            local speed = SPEED_MIN + math.random()*(SPEED_MAX-SPEED_MIN)
            local ang = math.random()*math.pi*2
            d.vx, d.vy = math.cos(ang)*speed, math.sin(ang)*speed
        end
    end
    connect(RunService.RenderStepped,function(dt)
        if not window.Visible then return end
        local w,h = bg.AbsoluteSize.X, bg.AbsoluteSize.Y
        if w<=0 or h<=0 or w<16 or h<16 then return end
        if w~=lastW or h~=lastH then seed(w,h); lastW,lastH=w,h end
        dt = math.min(dt or 1/60, 1/20)
        for _,d in ipairs(dots) do
            d.x = d.x + d.vx*dt
            d.y = d.y + d.vy*dt
            if d.x < 4 then d.x = 4; d.vx = -d.vx
            elseif d.x > w-4 then d.x = w-4; d.vx = -d.vx end
            if d.y < 4 then d.y = 4; d.vy = -d.vy
            elseif d.y > h-4 then d.y = h-4; d.vy = -d.vy end
            d.node.Position = UDim2.fromOffset(d.x,d.y)
        end
        local pairs = {}
        for i=1,DOT_COUNT do
            local a = dots[i]
            for j=i+1,DOT_COUNT do
                local b = dots[j]
                local dx,dy = b.x-a.x, b.y-a.y
                local d2 = dx*dx+dy*dy
                if d2 < LINK_DIST*LINK_DIST then
                    table.insert(pairs,{a=a,b=b,dx=dx,dy=dy,d2=d2})
                end
            end
        end
        table.sort(pairs,function(p,q) return p.d2 < q.d2 end)
        local used = math.min(#pairs,LINE_POOL)
        for k=1,LINE_POOL do
            local l = lines[k]
            if k<=used then
                local p = pairs[k]
                local dist = math.sqrt(p.d2)
                local closeness = 1 - dist/LINK_DIST
                l.Visible = true
                l.BackgroundTransparency = .82 - .72*closeness
                l.Size = UDim2.fromOffset(math.max(2,dist),1)
                l.Position = UDim2.fromOffset((p.a.x+p.b.x)/2,(p.a.y+p.b.y)/2)
                l.Rotation = math.deg(math.atan2(p.dy,p.dx))
            else
                l.Visible = false
            end
        end
    end)
end)()

local scale=new('UIScale',{},window)
text(window,'sakuravisuals.cc',21,UDim2.fromOffset(22,16),UDim2.new(1,-80,0,27))
local sub=text(window,'LOCAL VISUALS  /  только на твоём экране',11,UDim2.fromOffset(23,46),UDim2.new(1,-60,0,18)); sub.TextColor3=muted
local close=button(window,'×',UDim2.fromOffset(32,32),UDim2.new(1,-46,0,17))
connect(close.Activated,function() window.Visible=false end)
checkpoint('перетаскиваемая кнопка')
-- Draggable launcher: pointer drag is separate from click/keyboard activation.
;(function()
    local pointer=nil
    local lastDragged=false
    local suppressUntil=0
    local saved=env.SakuraLauncherPosition
    local placement={x=.5,y=0}
    if type(saved)=='table' and type(saved.x)=='number' and type(saved.y)=='number'
        and saved.x==saved.x and saved.y==saved.y then
        placement.x=math.clamp(saved.x,0,1); placement.y=math.clamp(saved.y,0,1)
    end
    local lastSize=nil
    launcher.ZIndex=100; launcher.Active=true
    local function usableSize()
        local camera=workspace.CurrentCamera
        local size=camera and camera.ViewportSize or Vector2.new(800,600)
        local topLeft,bottomRight=game:GetService('GuiService'):GetGuiInset()
        return Vector2.new(math.max(1,size.X-topLeft.X-bottomRight.X),math.max(1,size.Y-topLeft.Y-bottomRight.Y))
    end
    local function bounds(size)
        local pad=math.min(8,size.X/4,size.Y/4)
        local width=math.min(244,math.max(1,size.X-2*pad))
        local height=math.min(37,math.max(1,size.Y-2*pad))
        return pad,width,height,math.max(0,size.X-width-2*pad),math.max(0,size.Y-height-2*pad)
    end
    local function placeNormalized()
        local size=usableSize(); local pad,width,height,roomX,roomY=bounds(size)
        launcher.Size=UDim2.fromOffset(width,height)
        launcher.Position=UDim2.fromOffset(pad+roomX*placement.x,pad+roomY*placement.y)
        lastSize=size
    end
    local function moveTo(x,y)
        local size=usableSize(); local pad,width,height,roomX,roomY=bounds(size)
        x=math.clamp(x,pad,pad+roomX); y=math.clamp(y,pad,pad+roomY)
        placement.x=roomX>0 and (x-pad)/roomX or 0
        placement.y=roomY>0 and (y-pad)/roomY or 0
        launcher.Size=UDim2.fromOffset(width,height)
        launcher.Position=UDim2.fromOffset(x,y)
        lastSize=size
    end
    local function savePlacement()
        env.SakuraLauncherPosition={x=placement.x,y=placement.y}
    end
    local function pointerInput(input)
        return input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)
    end
    connect(launcher.InputBegan,function(input)
        if not pointerInput(input) or pointer then return end
        lastDragged=false; suppressUntil=0
        pointer={input=input,origin=Vector2.new(input.Position.X,input.Position.Y),
            start=Vector2.new(launcher.Position.X.Offset,launcher.Position.Y.Offset),dragged=false}
    end)
    connect(UIS.InputChanged,function(input)
        if not pointer then return end
        local mouse=pointer.input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement
        if input~=pointer.input and not mouse then return end
        local delta=Vector2.new(input.Position.X-pointer.origin.X,input.Position.Y-pointer.origin.Y)
        if delta.Magnitude>=7 then pointer.dragged=true end
        if pointer.dragged then
            suppressUntil=os.clock()+.25
            moveTo(pointer.start.X+delta.X,pointer.start.Y+delta.Y)
        end
    end)
    connect(UIS.InputEnded,function(input)
        if not pointer then return end
        if input~=pointer.input and not (pointer.input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1) then return end
        lastDragged=pointer.dragged
        if pointer.dragged then suppressUntil=os.clock()+.25; savePlacement() end
        pointer=nil
    end)
    connect(launcher.Activated,function(input)
        if pointerInput(input) then
            -- Activated may be dispatched before OR after InputEnded.
            if (pointer and pointer.dragged) or lastDragged or os.clock()<suppressUntil then return end
            if pointer and input.UserInputType==Enum.UserInputType.Touch and input~=pointer.input then return end
        elseif pointer and pointer.dragged then return end
        window.Visible=not window.Visible
    end)
    connect(UIS.WindowFocusReleased,function()
        if pointer then
            if pointer.dragged then savePlacement() end
            pointer=nil; lastDragged=true; suppressUntil=os.clock()+.25
        end
    end)
    connect(RunService.RenderStepped,function()
        local size=usableSize()
        if not lastSize or size.X~=lastSize.X or size.Y~=lastSize.Y then
            if pointer then pointer=nil; lastDragged=true; suppressUntil=os.clock()+.25 end
            placeNormalized()
        end
    end)
    placeNormalized()
end)()

local toast=text(gui,'',13,UDim2.new(.5,-170,1,-62),UDim2.fromOffset(340,48)); toast.TextWrapped=true; toast.TextXAlignment=Enum.TextXAlignment.Center; toast.BackgroundColor3=Color3.fromRGB(35,26,44); toast.BackgroundTransparency=.08; toast.Visible=false; round(toast)
local toastGeneration=0
local function notify(msg)
    if not alive then return end
    toastGeneration+=1; local gen=toastGeneration; toast.Text=msg; toast.Visible=true
    task.delay(4,function() if alive and gen==toastGeneration then toast.Visible=false end end)
end
local nav=new('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(18,83),Size=UDim2.new(0,145,1,-128),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=6,ScrollBarImageColor3=pink,ScrollingDirection=Enum.ScrollingDirection.Y},window)
new('UIListLayout',{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},nav)
text(window,'↕ Прокрутка вкладок',10,UDim2.new(0,20,1,-37),UDim2.fromOffset(145,20)).TextColor3=muted
local pages={}
local navigation={buttons={},count=0}
local function selectPage(selected)
    for _,p in pairs(pages) do p.Visible=p==selected end
    for p,b in pairs(navigation.buttons) do
        b.BackgroundColor3=p==selected and Color3.fromRGB(80,42,67) or Color3.fromRGB(43,35,54)
        b.TextColor3=p==selected and pink or Color3.fromRGB(244,234,249)
    end
end
-- Config registry. A config captures the whole menu, so pages tag themselves
-- with their name and every toggle/slider registers its own getter/setter pair
-- here instead of a hand-written list that would go stale on the next feature.
local cfgRegistry={order={},byKey={}}
local cfgExtras={order={},byKey={}}
local function cfgPageOf(frame)
    local step=frame
    while step do
        if step.GetAttribute then
            local ok,value=pcall(function() return step:GetAttribute('SakuraPage') end)
            if ok and value then return value end
        end
        step=step.Parent
    end
    return nil
end
local function cfgKeyFor(frame,title)
    local pageName=cfgPageOf(frame)
    local base=(pageName and (pageName..' • ') or '')..title
    local key,index=base,1
    while cfgRegistry.byKey[key] do index+=1; key=base..' ('..index..')' end
    return key
end
local function cfgRegister(frame,title,kind,get,set)
    local entry={key=cfgKeyFor(frame,title),title=title,kind=kind,get=get,set=set}
    cfgRegistry.byKey[entry.key]=entry
    table.insert(cfgRegistry.order,entry)
    return entry
end
-- Extras are settings that are neither a toggle nor a slider: the trail style,
-- the cape image id and the morph username.
local function cfgExtra(name,get,set)
    local entry={key=name,kind='extra',get=get,set=set}
    cfgExtras.byKey[name]=entry
    table.insert(cfgExtras.order,entry)
    return entry
end
local function page(title)
    local p=new('ScrollingFrame',{Name=title,Position=UDim2.fromOffset(179,83),Size=UDim2.new(1,-197,1,-105),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=pink,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},window)
    -- The page name is the first half of every config key, so settings stay
    -- readable and collisions between tabs are impossible.
    p:SetAttribute('SakuraPage',title)
    new('UIPadding',{PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,12)},p)
    new('UIListLayout',{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},p)
    pages[title]=p
    local b=button(nav,title,UDim2.new(1,-9,0,36))
    navigation.count+=1; b.LayoutOrder=navigation.count; navigation.buttons[p]=b
    connect(b.Activated,function() selectPage(p) end)
    return p
end
checkpoint('вкладки')
-- Keep the newest requested feature visible without scrolling.
local morphPage=page('Morph Player')
local mm2Page=page('MM2')
local configPage=page('Config')
local characterPage=page('Персонаж')
local catalogPage=page('Каталог')
local settingsPage=page('Настройки')
local espPage=page('ESP / друзья')
local worldPage=page('Мир / погода')
local shaderPage=page('Шейдеры')
local colorPage=page('Цвета')
local customPage=page('Кастомный игрок')
local modelsPage=page('Модельки')
local dancePage=page('Танцы')
local detectionPage=page('Юзер-ЧИТЕР')
selectPage(morphPage)
nav.CanvasPosition=Vector2.new(0,0)
local function note(p,s)
    local l=text(p,s,12,nil,UDim2.new(1,0,0,43)); l.TextWrapped=true; l.TextColor3=muted; l.AutomaticSize=Enum.AutomaticSize.Y; l.TextYAlignment=Enum.TextYAlignment.Top; return l
end
local function toggle(p,title,initial,callback)
    local value=initial
    local b=button(p,'')
    local function draw() b.Text=title..'   '..(value and '● ВКЛ' or '○ ВЫКЛ'); b.TextColor3=value and pink or Color3.fromRGB(224,215,232) end
    draw()
    connect(b.Activated,function() value=not value; draw(); callback(value) end)
    -- Config snapshot/restore hook. The callback only runs on an actual change,
    -- so loading a config never re-triggers a feature that is already on.
    cfgRegister(p,title,'toggle',function() return value end,function(v)
        if value==v then return end
        value=v; draw(); callback(v)
    end)
    return function(v) value=v; draw() end
end
local function dropdown(p,title,items,default,callback)
    local wrap=new('Frame',{Size=UDim2.new(1,0,0,36),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},p)
    new('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},wrap)
    local b=button(wrap,title..': '..default..'  ▾')
    local list=new('Frame',{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false},wrap)
    new('UIListLayout',{Padding=UDim.new(0,4)},list)
    local function populate(options)
        for _,c in ipairs(list:GetChildren()) do if c:IsA('GuiButton') then c:Destroy() end end
        for _,item in ipairs(options) do
            local label=type(item)=='table' and item.label or item
            local val=type(item)=='table' and item.value or item
            local row=button(list,label,UDim2.new(1,0,0,32))
            connect(row.Activated,function() list.Visible=false; b.Text=title..': '..label..'  ▾'; callback(val) end)
        end
    end
    populate(items)
    connect(b.Activated,function() list.Visible=not list.Visible end)
    return populate
end
local function numberSlider(parent,title,minimum,maximum,initial,suffix,callback)
    local row=new('Frame',{BackgroundColor3=Color3.fromRGB(30,24,39),BorderSizePixel=0,Size=UDim2.new(1,0,0,76)},parent); round(row,10)
    local caption=text(row,title,12,UDim2.fromOffset(12,7),UDim2.new(1,-98,0,24))
    local input=new('TextBox',{Text=tostring(initial),ClearTextOnFocus=false,Font=Enum.Font.Code,TextSize=13,
        TextColor3=pink,BackgroundColor3=Color3.fromRGB(46,36,57),BorderSizePixel=0,
        Position=UDim2.new(1,-80,0,7),Size=UDim2.fromOffset(68,26)},row); round(input,6)
    local area=new('TextButton',{Text='',AutoButtonColor=false,BackgroundTransparency=1,
        Position=UDim2.fromOffset(18,36),Size=UDim2.new(1,-36,0,32)},row)
    local track=new('Frame',{BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(61,50,71),
        Position=UDim2.new(0,0,.5,-4),Size=UDim2.new(1,0,0,8)},area); round(track,4)
    local fill=new('Frame',{BorderSizePixel=0,BackgroundColor3=pink,Size=UDim2.fromScale(0,1)},track); round(fill,4)
    local knob=new('Frame',{BorderSizePixel=0,BackgroundColor3=Color3.new(1,1,1),AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(17,17)},track); round(knob,9)
    local value=initial
    local function set(v)
        value=math.clamp(math.floor(v+.5),minimum,maximum)
        input.Text=tostring(value)..suffix
        local fraction=(value-minimum)/(maximum-minimum)
        fill.Size=UDim2.fromScale(fraction,1); knob.Position=UDim2.fromScale(fraction,.5)
        callback(value)
    end
    local drag=nil
    local function move(x) set(minimum+math.clamp((x-area.AbsolutePosition.X)/math.max(1,area.AbsoluteSize.X),0,1)*(maximum-minimum)) end
    connect(area.InputBegan,function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=i; parent.ScrollingEnabled=false; move(i.Position.X)
        end
    end)
    connect(UIS.InputChanged,function(i)
        if drag and (i==drag or (drag.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement)) then move(i.Position.X) end
    end)
    connect(UIS.InputEnded,function(i)
        if drag and (i==drag or (drag.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseButton1)) then drag=nil; parent.ScrollingEnabled=true end
    end)
    connect(UIS.WindowFocusReleased,function() drag=nil; parent.ScrollingEnabled=true end)
    connect(input.FocusLost,function()
        local v=tonumber(input.Text:match('[-+]?%d+%.?%d*'))
        if v then set(v) else set(value); notify('Введи число от '..minimum..' до '..maximum) end
    end)
    set(initial)
    cfgRegister(parent,title,'slider',function() return value end,set)
end

-- Config core: JSON, permanent config ids and the capture/apply pair. Plain
-- table and string work, so it is covered by tests/configs.luau outside Roblox.
local cfgCore={}
do
    -- --------------------------------------------------------------- JSON ---
    -- Self-contained encoder/decoder on purpose: no HttpService, no file API
    -- assumptions, one code path that the mock tests can exercise.
    local escapeMap={['"']='\\"',['\\']='\\\\',['\b']='\\b',['\f']='\\f',['\n']='\\n',['\r']='\\r',['\t']='\\t'}
    local function escapeChar(c)
        local known=escapeMap[c]
        if known then return known end
        return string.format('\\u%04X',string.byte(c))
    end
    local function quote(value)
        return '"'..value:gsub('[%z\1-\31\\"]',escapeChar)..'"'
    end
    local function isArray(t)
        local count=0
        for key in pairs(t) do
            if type(key)~='number' then return false end
            count+=1
        end
        return count==#t
    end
    local function numberText(n)
        if n~=n or n==math.huge or n==-math.huge then return nil end
        if math.floor(n)==n and math.abs(n)<1e15 then return string.format('%d',n) end
        return string.format('%.14g',n)
    end
    local encodeValue
    function encodeValue(value,seen)
        local kind=type(value)
        if kind=='boolean' then return value and 'true' or 'false' end
        if kind=='number' then return numberText(value) end
        if kind=='string' then return quote(value) end
        if kind~='table' then return nil end
        if seen[value] then return nil end
        seen[value]=true
        local parts={}
        if isArray(value) then
            for index=1,#value do
                local item=encodeValue(value[index],seen)
                if not item then seen[value]=nil; return nil end
                parts[index]=item
            end
            seen[value]=nil
            return '['..table.concat(parts,',')..']'
        end
        local keys={}
        for key in pairs(value) do
            if type(key)~='string' then seen[value]=nil; return nil end
            table.insert(keys,key)
        end
        table.sort(keys)
        for _,key in ipairs(keys) do
            local item=encodeValue(value[key],seen)
            if not item then seen[value]=nil; return nil end
            table.insert(parts,quote(key)..':'..item)
        end
        seen[value]=nil
        return '{'..table.concat(parts,',')..'}'
    end
    function cfgCore.encode(value)
        local ok,text=pcall(encodeValue,value,{})
        if ok and type(text)=='string' then return text end
        return nil
    end
    local function skipSpace(text,index)
        while index<=#text do
            local c=text:sub(index,index)
            if c==' ' or c=='\t' or c=='\n' or c=='\r' then index+=1 else break end
        end
        return index
    end
    local function decodeString(text,index)
        local out={}
        local i=index+1
        while true do
            local c=text:sub(i,i)
            if c=='' then return nil end
            if c=='"' then return table.concat(out),i+1 end
            if c=='\\' then
                local esc=text:sub(i+1,i+1)
                if esc=='u' then
                    local code=tonumber(text:sub(i+2,i+5),16)
                    if not code then return nil end
                    if code<0x80 then table.insert(out,string.char(code))
                    elseif code<0x800 then table.insert(out,string.char(0xC0+math.floor(code/64),0x80+code%64))
                    else table.insert(out,string.char(0xE0+math.floor(code/4096),0x80+math.floor(code/64)%64,0x80+code%64)) end
                    i+=6
                else
                    local simple={['"']='"',['\\']='\\',['/']='/',['b']='\b',['f']='\f',['n']='\n',['r']='\r',['t']='\t'}
                    local actual=simple[esc]
                    if not actual then return nil end
                    table.insert(out,actual)
                    i+=2
                end
            else
                table.insert(out,c)
                i+=1
            end
        end
    end
    local decodeValue
    function decodeValue(text,index,depth)
        if depth>40 then return nil end
        index=skipSpace(text,index)
        local c=text:sub(index,index)
        if c=='' then return nil end
        if c=='"' then return decodeString(text,index) end
        if c=='{' then
            local result={}
            index=skipSpace(text,index+1)
            if text:sub(index,index)=='}' then return result,index+1 end
            while true do
                if text:sub(index,index)~='"' then return nil end
                local key,after=decodeString(text,index)
                if not key then return nil end
                index=skipSpace(text,after)
                if text:sub(index,index)~=':' then return nil end
                local value,nextIndex=decodeValue(text,index+1,depth+1)
                if value==nil then return nil end
                result[key]=value
                index=skipSpace(text,nextIndex)
                local separator=text:sub(index,index)
                if separator==',' then index=skipSpace(text,index+1)
                elseif separator=='}' then return result,index+1
                else return nil end
            end
        end
        if c=='[' then
            local result={}
            index=skipSpace(text,index+1)
            if text:sub(index,index)==']' then return result,index+1 end
            while true do
                local value,nextIndex=decodeValue(text,index,depth+1)
                if value==nil then return nil end
                table.insert(result,value)
                index=skipSpace(text,nextIndex)
                local separator=text:sub(index,index)
                if separator==',' then index=skipSpace(text,index+1)
                elseif separator==']' then return result,index+1
                else return nil end
            end
        end
        if text:sub(index,index+3)=='true' then return true,index+4 end
        if text:sub(index,index+4)=='false' then return false,index+5 end
        local numberString=text:match('^%-?%d+%.?%d*[eE][%-+]?%d+',index) or text:match('^%-?%d+%.?%d*',index) or text:match('^%-?%.%d+',index)
        if not numberString then return nil end
        local number=tonumber(numberString)
        if not number then return nil end
        return number,index+#numberString
    end
    function cfgCore.decode(text)
        if type(text)~='string' or #text==0 then return nil end
        local ok,value,index=pcall(function()
            local parsed,after=decodeValue(text,1,0)
            return parsed,after
        end)
        if not ok or value==nil then return nil end
        if skipSpace(text,index or #text+1)<=#text then return nil end
        return value
    end

    -- ---------------------------------------------------------------- ids ---
    -- Permanent keys of the form sv-123456. They are never edited: only the
    -- name can change. Anything else in the field is rejected.
    function cfgCore.parseId(raw)
        local value=tostring(raw or ''):match('^%s*(.-)%s*$')
        if value=='' then return nil end
        local digits=value:lower():match('^sv%-(%d+)$')
        if not digits or #digits>12 then return nil end
        return 'sv-'..digits
    end
    function cfgCore.newId(isUsed)
        for _=1,400 do
            local candidate='sv-'..string.format('%06d',math.random(0,999999))
            if not isUsed(candidate) then return candidate end
        end
        local stamp=string.format('%06d',os.time()%1000000)
        local candidate='sv-'..stamp
        local index=0
        while isUsed(candidate) do index+=1; candidate='sv-'..stamp..index end
        return candidate
    end
    function cfgCore.hex(color)
        -- Color3 is userdata in Roblox and a table in the mock tests.
        local kind=type(color)
        if kind~='table' and kind~='userdata' then return nil end
        local r,g,b=color.R,color.G,color.B
        if type(r)~='number' or type(g)~='number' or type(b)~='number' then return nil end
        return string.format('#%02X%02X%02X',math.floor(r*255+.5),math.floor(g*255+.5),math.floor(b*255+.5))
    end
    function cfgCore.unhex(text)
        local r,g,b=tostring(text or ''):match('^#(%x%x)(%x%x)(%x%x)$')
        if not r then return nil end
        return Color3.fromRGB(tonumber(r,16),tonumber(g,16),tonumber(b,16))
    end

    -- ------------------------------------------------- capture and apply ---
    -- The Config tab is never part of a config: its own toggle would otherwise
    -- fight with the file it is stored in.
    local function ignored(entry) return entry.key:sub(1,6)=='Config' end
    function cfgCore.capture(registry,extras,colorTable)
        local data={toggles={},sliders={},extras={},colors={}}
        for _,entry in ipairs(registry or {}) do
            if not ignored(entry) then
                local ok,value=pcall(entry.get)
                if ok then
                    if entry.kind=='toggle' then data.toggles[entry.key]=value and true or false
                    elseif entry.kind=='slider' and type(value)=='number' then data.sliders[entry.key]=value end
                end
            end
        end
        for _,entry in ipairs(extras or {}) do
            if not ignored(entry) then
                local ok,value=pcall(entry.get)
                if ok and (type(value)=='string' or type(value)=='boolean' or type(value)=='number') then data.extras[entry.key]=value end
            end
        end
        for key,value in pairs(colorTable or {}) do
            local hex=cfgCore.hex(value)
            if hex then data.colors[key]=hex end
        end
        return data
    end
    function cfgCore.count(data)
        local total=0
        for _,group in pairs({(data or {}).toggles or {},(data or {}).sliders or {},(data or {}).extras or {},(data or {}).colors or {}}) do
            for _ in pairs(group) do total+=1 end
        end
        return total
    end
    -- Order matters: colours first, then extras (trail style, cape image, morph
    -- username) because the toggles read them, then sliders, and toggles last
    -- because they switch features on and some of them are heavy.
    function cfgCore.apply(data,registry,extras,applyColor,step)
        local applied,missed=0,{}
        local toggles,sliders={},{}
        for _,entry in ipairs(registry or {}) do
            if entry.kind=='toggle' then toggles[entry.key]=entry elseif entry.kind=='slider' then sliders[entry.key]=entry end
        end
        local extrasByKey={}
        for _,entry in ipairs(extras or {}) do extrasByKey[entry.key]=entry end
        local function use(entry,value)
            if not entry then table.insert(missed,'?') return end
            local ok=pcall(entry.set,value)
            if ok then applied+=1 else table.insert(missed,entry.key) end
        end
        for key,hex in pairs((data or {}).colors or {}) do
            local color=cfgCore.unhex(hex)
            if color and applyColor then
                local ok=pcall(applyColor,key,color)
                if ok then applied+=1 else table.insert(missed,key) end
            else
                table.insert(missed,key)
            end
        end
        if step then step('colors') end
        for key,value in pairs((data or {}).extras or {}) do
            local entry=extrasByKey[key]
            if entry then use(entry,value) else table.insert(missed,key) end
        end
        if step then step('extras') end
        for key,value in pairs((data or {}).sliders or {}) do
            local entry=sliders[key]
            if entry then use(entry,value) else table.insert(missed,key) end
        end
        if step then step('sliders') end
        for key,value in pairs((data or {}).toggles or {}) do
            local entry=toggles[key]
            if entry then use(entry,value and true or false) else table.insert(missed,key) end
        end
        if step then step('toggles') end
        table.sort(missed)
        return applied,missed
    end

    -- -------------------------------------------------------------- store ---
    function cfgCore.blankStore()
        return {configs={},autoload=nil}
    end
    function cfgCore.readStore(text)
        local source=text
        if type(source)~='table' then source=cfgCore.decode(source) end
        if type(source)~='table' then return nil end
        local store=cfgCore.blankStore()
        for rawId,config in pairs(source.configs or {}) do
            local id=cfgCore.parseId(rawId)
            if id and type(config)=='table' then
                local name=type(config.name)=='string' and config.name:sub(1,40) or id
                if name:match('^%s*$') then name=id end
                store.configs[id]={id=id,name=name,created=tonumber(config.created) or 0,updated=tonumber(config.updated) or 0,data=type(config.data)=='table' and config.data or {}}
            end
        end
        local autoload=cfgCore.parseId(source.autoload)
        if autoload and store.configs[autoload] then store.autoload=autoload end
        return store
    end
    function cfgCore.writeStore(store)
        return cfgCore.encode({configs=store.configs,autoload=store.autoload})
    end
    function cfgCore.upsert(store,id,name)
        local config=store.configs[id]
        if not config then
            config={id=id,name=(name and name~='') and name or id,created=os.time(),updated=os.time(),data={toggles={},sliders={},extras={},colors={}}}
            store.configs[id]=config
        elseif name and name~='' then
            config.name=name
            config.updated=os.time()
        end
        return config
    end
    function cfgCore.list(store)
        local list={}
        for _,config in pairs(store.configs) do table.insert(list,config) end
        table.sort(list,function(a,b)
            if a.updated==b.updated then return a.id<b.id end
            return a.updated>b.updated
        end)
        return list
    end
    function cfgCore.remove(store,id)
        if not store.configs[id] then return false end
        store.configs[id]=nil
        if store.autoload==id then store.autoload=nil end
        return true
    end
end

local original={}
for _,k in ipairs({'ClockTime','Brightness','FogStart','FogEnd','FogColor','Ambient','OutdoorAmbient','ExposureCompensation','ColorShift_Top','GlobalShadows'}) do original[k]=Lighting[k] end
local originalSky=Lighting:FindFirstChildOfClass('Sky')
local ownedSky=nil
local hiddenAtmospheres={}
local shaderObjects={}
local friends, friendStatus={},{}
local selected=me
local state={hat=false,jump=false,target=false,rain=false,snow=false,fog=false,glow=false,lightFog=false}
local wanted={} -- per-player effects remain bound to the selected player
local function config(p) if not wanted[p] then wanted[p]={trail=false,cape=false,esp=false} end; return wanted[p] end
local function charRoot(p) return p.Character and p.Character:FindFirstChild('HumanoidRootPart') end
local friendRefreshUI
local function scan(p)
    friendStatus[p]='checking'
    task.spawn(function()
        local success,result=pcall(function() return me:IsFriendsWith(p.UserId) end)
        if not alive or p.Parent~=Players then return end
        friends[p]=success and result or false
        friendStatus[p]=success and (result and 'friend' or 'other') or 'unknown'
        if friendRefreshUI then friendRefreshUI() end
    end)
end
note(characterPage,'Трейл и плащ: выбери себя или подтверждённого друга. Эффекты сохраняются после респавна.')
local setTrail,setCape
local refreshTargets=dropdown(characterPage,'Эффекты для',{{label='Я',value=me}},'Я',function(p)
    selected=p
    if setTrail then setTrail(config(p).trail); setCape(config(p).cape) end
end)
local function requireTarget()
    if selected.Parent~=Players then selected=me end
    if selected~=me and not friends[selected] then notify('Игрок не подтверждён как друг.'); return nil end
    return selected
end
local function destroyEffect(p,key)
    if effects[p] and effects[p][key] then
        local e=effects[p][key]
        for _,o in ipairs(e.objects or {}) do pcall(function() o:Destroy() end) end
        if e.spawn then for _,it in ipairs(e.spawn.parts) do pcall(function() it.part:Destroy() end) end end
        effects[p][key]=nil
    end
end
checkpoint('трейл')
-- Trail styles. 'Линия' is the classic ribbon Trail; particle styles hang a
-- local Attachment with emitters on the root; 'Лепестки' and 'Орбы' are
-- anchored parts spawned along the path and animated in the render loop.
-- One table keeps the main chunk under Luau's local-variable limit.
local trailFX={style='Линия',styles={'Линия','Лепестки','Искры','Орбы','Дым','Огонь'}}
do
    local white=Color3.new(1,1,1)
    local textures={sparkles='rbxasset://textures/particles/sparkles_main.dds',smoke='rbxasset://textures/particles/smoke_main.dds',fire='rbxasset://textures/particles/fire_main.dds'}
    local function kp(t,v) return NumberSequenceKeypoint.new(t,v) end
    local function ck(t,c) return ColorSequenceKeypoint.new(t,c) end
    function trailFX.particleColor(name,c)
        if name=='Sparks' then return ColorSequence.new(c:Lerp(white,.45),c)
        elseif name=='Smoke' then return ColorSequence.new(c:Lerp(white,.4),c:Lerp(white,.78))
        elseif name=='Fire' then return ColorSequence.new({ck(0,c:Lerp(white,.55)),ck(.35,c),ck(1,shade(c))})
        elseif name=='FireSparks' then return ColorSequence.new(c:Lerp(white,.5))
        end
        return ColorSequence.new(c)
    end
    local specs={}
    specs['Искры']=function() return {
        {Name='Sparks',Texture=textures.sparkles,Rate=48,Lifetime=NumberRange.new(.6,1.1),Speed=NumberRange.new(2.5,6),SpreadAngle=Vector2.new(40,40),EmissionDirection=Enum.NormalId.Back,Acceleration=Vector3.new(0,-9,0),Drag=1,Size=NumberSequence.new({kp(0,.1),kp(.25,.32),kp(1,0)}),Transparency=NumberSequence.new({kp(0,0),kp(.7,.1),kp(1,1)}),LightEmission=1,LightInfluence=0,RotSpeed=NumberRange.new(-180,180),Rotation=NumberRange.new(0,360)},
    } end
    specs['Дым']=function() return {
        {Name='Smoke',Texture=textures.smoke,Rate=24,Lifetime=NumberRange.new(1.3,1.9),Speed=NumberRange.new(.8,1.8),SpreadAngle=Vector2.new(25,25),EmissionDirection=Enum.NormalId.Back,Acceleration=Vector3.new(0,.7,0),Size=NumberSequence.new({kp(0,.5),kp(1,2.1)}),Transparency=NumberSequence.new({kp(0,.5),kp(.6,.75),kp(1,1)}),LightEmission=.15,LightInfluence=.6,RotSpeed=NumberRange.new(-25,25),Rotation=NumberRange.new(0,360)},
    } end
    specs['Огонь']=function() return {
        {Name='Fire',Texture=textures.fire,Rate=60,Lifetime=NumberRange.new(.45,.8),Speed=NumberRange.new(2,3.5),SpreadAngle=Vector2.new(12,12),EmissionDirection=Enum.NormalId.Top,Acceleration=Vector3.new(0,2,0),Size=NumberSequence.new({kp(0,.4),kp(.3,1),kp(1,.15)}),Transparency=NumberSequence.new({kp(0,.15),kp(.6,.35),kp(1,1)}),LightEmission=1,LightInfluence=0,RotSpeed=NumberRange.new(-60,60),Rotation=NumberRange.new(0,360)},
        {Name='FireSparks',Texture=textures.sparkles,Rate=16,Lifetime=NumberRange.new(.6,1),Speed=NumberRange.new(3,6),SpreadAngle=Vector2.new(30,30),EmissionDirection=Enum.NormalId.Top,Acceleration=Vector3.new(0,-3,0),Size=NumberSequence.new({kp(0,.12),kp(1,0)}),Transparency=NumberSequence.new(.1),LightEmission=1,LightInfluence=0},
    } end
    function trailFX.build(e,r,own)
        local style=trailFX.style; e.style=style
        local c=colors.trail
        if style=='Линия' then
            local a=own(new('Attachment',{Position=Vector3.new(-.85,.25,.5)},r))
            local b=own(new('Attachment',{Position=Vector3.new(.85,.25,.5)},r))
            own(new('Trail',{Attachment0=a,Attachment1=b,Lifetime=1.15,MinLength=.05,LightEmission=.8,FaceCamera=true,Color=ColorSequence.new(c,c:Lerp(white,.35)),Transparency=NumberSequence.new({kp(0,.18),kp(1,1)})},r))
        elseif specs[style] then
            local at=own(new('Attachment',{Name='SakuraTrailFX',Position=Vector3.new(0,-.1,.55)},r))
            for _,props in ipairs(specs[style]()) do
                props.Color=trailFX.particleColor(props.Name,c)
                own(new('ParticleEmitter',props,at))
            end
            if style=='Огонь' then own(new('PointLight',{Name='SakuraTrailLight',Color=c,Brightness=1.1,Range=9,Shadows=false},at)) end
        else
            e.spawn={style=style,last=r.Position,timer=0,idle=0,parts={}}
        end
    end
    local function rnd(a,b) return a+math.random()*(b-a) end
    function trailFX.update(e,r,dt,t)
        local s=e.spawn; local petals=s.style=='Лепестки'
        local pos=r.Position
        s.timer+=dt; s.idle+=dt
        local moved=(pos-s.last).Magnitude
        -- Orbs only mark movement; petals also drift down slowly while standing.
        if (s.timer>=(petals and .08 or .06) and moved>=.3) or (petals and s.idle>=.26) then
            s.timer=0; s.idle=0; s.last=pos
            local c=colors.trail; local part,item
            if petals then
                part=new('Part',{Name='TrailPetal',Shape=Enum.PartType.Ball,Size=Vector3.new(.44,.1,.3),Material=Enum.Material.Neon,Color=c:Lerp(white,math.random()*.35),Transparency=.2,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false},root)
                item={part=part,born=t,life=rnd(1.5,2),origin=(r.CFrame*CFrame.new(rnd(-.9,.9),rnd(-.6,1),rnd(.7,1.3))).Position,phase=rnd(0,6.28),spin=Vector3.new(rnd(-3,3),rnd(-3,3),rnd(-3,3)),velocity=Vector3.new(rnd(-.7,.7),-rnd(1.4,2.6),rnd(-.7,.7))}
            else
                part=new('Part',{Name='TrailOrb',Shape=Enum.PartType.Ball,Size=Vector3.new(.55,.55,.55),Material=Enum.Material.Neon,Color=c,Transparency=.12,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false},root)
                item={part=part,born=t,life=1.05,origin=(r.CFrame*CFrame.new(rnd(-.25,.25),rnd(-.9,.7),.75)).Position,velocity=Vector3.new(0,.35,0)}
            end
            part.CFrame=CFrame.new(item.origin)
            table.insert(s.parts,item)
            if #s.parts>70 then local old=table.remove(s.parts,1); pcall(function() old.part:Destroy() end) end
        end
        for i=#s.parts,1,-1 do
            local it=s.parts[i]; local age=t-it.born; local k=age/it.life
            if k>=1 or not it.part.Parent then pcall(function() it.part:Destroy() end); table.remove(s.parts,i)
            elseif petals then
                local sway=Vector3.new(math.sin(t*2.4+it.phase)*.4*age,0,math.cos(t*1.9+it.phase)*.3*age)
                it.part.CFrame=CFrame.new(it.origin+it.velocity*age+sway)*CFrame.Angles(it.spin.X*age,it.spin.Y*age,it.spin.Z*age)
                it.part.Transparency=k<.6 and .2 or .2+(k-.6)/.4*.8
            else
                local d=.55*(1-.8*k)
                it.part.Size=Vector3.new(d,d,d)
                it.part.CFrame=CFrame.new(it.origin+it.velocity*age)
                it.part.Transparency=.12+.88*k*k
            end
        end
    end
end
checkpoint('картинка на плащ')
-- Cape image: any Roblox decal/image ID is put on a plate that hangs on the
-- cape surface, behind the 16 coloured layers, and follows their bend. One
-- table keeps the main chunk under Luau's local-variable limit.
local capeFX={image='',white=true,transparency=.15,width=1.72,height=1.3,scale=1,layers=16}
do
    local WHITE=Color3.new(1,1,1)
    -- Accepts a bare ID, rbxassetid://ID or any link that ends with an ID.
    function capeFX.parseId(raw)
        local value=tostring(raw or ''):match('^%s*(.-)%s*$')
        local id=value:match('^%d+$') or value:match('assetid://(%d+)') or value:match('/(%d+)')
        if not id or #id>16 or tonumber(id)<=0 then return nil end
        return id
    end
    -- A marketplace answer is only a hint: an unreachable answer never blocks
    -- the user, a clearly different asset type does.
    function capeFX.accept(info)
        if not info then return true end
        local kind=info.AssetTypeId
        if kind==nil then return true end
        if type(kind)=='string' then local low=kind:lower(); return low:find('decal')~=nil or low:find('image')~=nil end
        return kind==13 or kind==1
    end
    function capeFX.fit()
        return capeFX.width,capeFX.height*capeFX.scale
    end
    -- Colour, transparency, image and size of every live cape in one place, so
    -- sliders never rebuild the parts and never flicker.
    function capeFX.dress(e)
        for index=1,#(e.segments or {}) do
            local part=e.segments[index]
            part.Color=colors.cape:Lerp(shade(colors.cape),index/capeFX.layers)
            part.Transparency=capeFX.transparency
        end
        local plate=e.picture; if not plate then return end
        local on=capeFX.image~=''
        local width,height=capeFX.fit()
        plate.Size=Vector3.new(width,height,.02)
        plate.Color=capeFX.white and WHITE or colors.cape:Lerp(WHITE,.4)
        plate.Transparency=on and capeFX.transparency or 1
        local texture=e.pictureTexture; if not texture then return end
        if on then
            texture.Texture='rbxassetid://'..capeFX.image
            texture.Transparency=0
            texture.StudsPerTileU=width
            texture.StudsPerTileV=height
            texture.OffsetStudsU=0
            texture.OffsetStudsV=0
        else
            texture.Texture=''
            texture.Transparency=1
        end
    end
    function capeFX.build(e,own)
        e.segments={}
        for index=1,capeFX.layers do
            local width=1.8+index*.025
            e.segments[index]=own(new('Part',{Name='CapeLayer'..index,Size=Vector3.new(width,.19,.065),Anchored=true,CanCollide=false,
                CanTouch=false,CanQuery=false,CastShadow=false,Material=Enum.Material.SmoothPlastic},root))
        end
        e.picture=own(new('Part',{Name='CapePicture',Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,
            Material=Enum.Material.SmoothPlastic},root))
        e.pictureTexture=own(new('Texture',{Name='CapePictureImage'},e.picture))
        capeFX.dress(e)
    end
    -- The plate hangs on the cape surface: the ninth layer is the middle of the
    -- visible cape, and 0.12 studs behind it is clear of the layers even at the
    -- strongest bend of the walk cycle.
    function capeFX.follow(e,fallback)
        local plate=e.picture; if not plate then return end
        local base=e.segments and e.segments[9] and e.segments[9].CFrame
        plate.CFrame=(base or fallback or CFrame.new(0,-10000,0))*CFrame.new(0,0,.12)
    end
    function capeFX.refresh()
        for _,entries in pairs(effects) do
            local e=entries.cape
            if e and e.segments then capeFX.dress(e) end
        end
    end
end
local function setEffect(p,key,on)
    destroyEffect(p,key)
    if not on then return end
    local r=charRoot(p); if not r then return end
    effects[p]=effects[p] or {}; local e={objects={},character=p.Character}; effects[p][key]=e
    local function own(o) table.insert(e.objects,o); return o end
    if key=='trail' then
        trailFX.build(e,r,own)
    elseif key=='cape' then
        capeFX.build(e,own)
    elseif key=='esp' then
        own(new('Highlight',{Name='FriendESP',Adornee=p.Character,FillColor=colors.esp,FillTransparency=.85,OutlineColor=colors.esp,OutlineTransparency=.1,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},root))
        local tag=own(new('BillboardGui',{Adornee=p.Character:FindFirstChild('Head') or r,AlwaysOnTop=true,Size=UDim2.fromOffset(210,32),StudsOffset=Vector3.new(0,2.5,0)},gui))
        local l=text(tag,p.DisplayName..'  @'..p.Name,12,nil,UDim2.fromScale(1,1)); l.TextXAlignment=Enum.TextXAlignment.Center; l.TextColor3=colors.esp; l:SetAttribute('SakuraNoTranslate',true)
    end
end
local trailStyleRow
setTrail=toggle(characterPage,'Трейл',false,function(on) local p=requireTarget(); if p then config(p).trail=on; setEffect(p,'trail',on); trailStyleRow.Visible=on else setTrail(false) end end)
do
    -- The style picker only appears once the trail is on; the same setTrail
    -- keeps it in sync when the target player changes.
    local raw=setTrail
    setTrail=function(v) raw(v); if trailStyleRow then trailStyleRow.Visible=v and true or false end end
    trailStyleRow=new('Frame',{Name='TrailStyles',Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false},characterPage)
    new('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},trailStyleRow)
    local header=text(trailStyleRow,'Вид трейла • цвет берётся из вкладки «Цвета»',12,nil,UDim2.new(1,0,0,18)); header.TextColor3=muted; header.LayoutOrder=1
    local grid=new('Frame',{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=2},trailStyleRow)
    new('UIGridLayout',{CellSize=UDim2.new(0,104,0,30),CellPadding=UDim2.new(0,6,0,6),SortOrder=Enum.SortOrder.LayoutOrder},grid)
    local buttons={}
    local function draw()
        for name,b in pairs(buttons) do
            local on=name==trailFX.style
            b.BackgroundColor3=on and Color3.fromRGB(80,42,67) or Color3.fromRGB(43,35,54)
            b.TextColor3=on and pink or Color3.fromRGB(244,234,249)
        end
    end
    for i,name in ipairs(trailFX.styles) do
        local b=button(grid,name,UDim2.new(0,104,0,30)); b.LayoutOrder=i; buttons[name]=b
        connect(b.Activated,function() trailFX.style=name; trailFX.apply(); notify('Вид трейла: '..name) end)
    end
    draw()
    -- Redraws the picker and rebuilds every live trail; also used when a config
    -- restores the style.
    trailFX.apply=function()
        draw()
        local players={}
        for p,entries in pairs(effects) do if entries.trail and config(p).trail then table.insert(players,p) end end
        for _,p in ipairs(players) do setEffect(p,'trail',true) end
    end
    cfgExtra('Трейл • вид',function() return trailFX.style end,function(value)
        if type(value)~='string' then return end
        for _,name in ipairs(trailFX.styles) do if name==value then trailFX.style=name; trailFX.apply(); return end end
    end)
end
setCape=toggle(characterPage,'Плащ • 16 слоёв',false,function(on) local p=requireTarget(); if p then config(p).cape=on; setEffect(p,'cape',on) else setCape(false) end end)
do
    -- Cape image UI. Visible only while the cape itself is on; the picture is
    -- a plain Roblox decal/image ID and only ever touches local parts.
    local Marketplace=game:GetService('MarketplaceService')
    local row=new('Frame',{Name='CapeImage',Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false},characterPage)
    new('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},row)
    local header=text(row,'Картинка на плащ • вставь ID и нажми «Поставить картинку»',12,nil,UDim2.new(1,0,0,18)); header.TextColor3=muted
    note(row,'Плащ с картинкой: включи «Плащ • 16 слоёв», вставь ID картинки и нажми «Поставить картинку». Картинка висит на поверхности плаща, повторяет его изгиб, а 16 слоёв остаются цветной рамкой. Всё локально — другие игроки картинку не видят.')
    local inputRow=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)},row)
    local imageInput=new('TextBox',{PlaceholderText='ID картинки / ссылка (декаль Roblox)',ClearTextOnFocus=false,Font=Enum.Font.Code,TextSize=13,
        TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(43,35,54),BorderSizePixel=0,Size=UDim2.new(.66,-6,1,0)},inputRow); round(imageInput,8)
    local applyButton=button(inputRow,'Поставить картинку',UDim2.new(.34,0,1,0),UDim2.fromScale(.66,0))
    local status=note(row,'Картинка: не задана')
    local clearButton=button(row,'Убрать картинку')
    toggle(row,'Плащ • картинка: белый фон (без подкраски)',true,function(on) capeFX.white=on; capeFX.refresh() end)
    numberSlider(row,'Высота картинки',60,130,100,'%',function(v) capeFX.scale=v/100; capeFX.refresh() end)
    numberSlider(row,'Прозрачность плаща',0,90,15,'%',function(v) capeFX.transparency=v/100; capeFX.refresh() end)
    note(row,'ID или ссылка: подойдёт ID декали, картинки Roblox или ссылка вида roblox.com/catalog/…. Прозрачные места картинки показывают цвет плаща, «белый фон» убирает подкраску.')
    local function drawStatus()
        status.Text=capeFX.image~='' and ('Картинка: ID '..capeFX.image) or 'Картинка: не задана'
    end
    local adding=false
    local function put()
        if adding then return end
        local id=capeFX.parseId(imageInput.Text)
        if not id then notify('Введи ID картинки или ссылку на декаль Roblox.'); return end
        if id==capeFX.image then notify('Эта картинка уже стоит на плаще.'); return end
        adding=true; applyButton.Text='Проверяю…'
        task.spawn(function()
            local ok,info=pcall(function() return Marketplace:GetProductInfo(tonumber(id),Enum.InfoType.Asset) end)
            adding=false; applyButton.Text='Поставить картинку'
            if not alive then return end
            if ok and not capeFX.accept(info) then notify('Это не картинка/декаль Roblox — нужен ID картинки.'); return end
            if not ok then notify('Магазин не ответил — ставлю картинку как есть.') end
            capeFX.image=id; capeFX.refresh(); drawStatus()
            notify('Картинка поставлена на плащ.')
            if not config(selected).cape then notify('Плащ выключен: включи «Плащ • 16 слоёв», чтобы картинка появилась.') end
        end)
    end
    connect(applyButton.Activated,put)
    connect(imageInput.FocusLost,function(enter) if enter then put() end end)
    connect(clearButton.Activated,function()
        capeFX.image=''; capeFX.refresh(); drawStatus(); notify('Картинка снята с плаща.')
    end)
    -- The block is always visible, even with the cape off: it is where the
    -- image ID is entered, and the note above says to switch the cape on.
    drawStatus()
    cfgExtra('Картинка на плащ • ID',function() return capeFX.image end,function(value)
        -- An empty saved value means "no image": a config must restore that too.
        if value=='' or value==nil then
            capeFX.image=''
            capeFX.refresh()
            drawStatus()
            return
        end
        local id=capeFX.parseId(value)
        if not id then return end
        capeFX.image=id
        capeFX.refresh()
        drawStatus()
    end)
end
local hat,hatOffset,hatBusy=nil,nil,false
local hatDrawingMode=false
local hatTriangles={}
local setDrawingToggle
local function clearHatDrawing()
    for _,triangle in ipairs(hatTriangles) do
        pcall(function() triangle.Visible=false end)
        local removed=pcall(function() triangle:Remove() end)
        if not removed then pcall(function() triangle:Destroy() end) end
    end
    hatTriangles={}
end
local function createHatDrawing()
    clearHatDrawing()
    local success,err=pcall(function()
        assert(Drawing and Drawing.new,'Drawing API отсутствует')
        for i=1,40 do
            local tri=Drawing.new('Triangle')
            table.insert(hatTriangles,tri)
            tri.Visible=false; tri.Filled=true; tri.Thickness=1
            tri.Color=colors.hat; tri.Transparency=1-hatTransparency
        end
    end)
    if not success then
        clearHatDrawing()
        notify('Drawing mode недоступен: '..tostring(err))
        return false
    end
    return true
end
local function loadHat()
    if hatBusy or hat then return end
    hatBusy=true
    task.spawn(function()
        local success,assets=pcall(function() return game:GetObjects('rbxassetid://12417021356') end)
        hatBusy=false
        if not success or not assets or #assets==0 then notify('Шляпа: ассет 12417021356 недоступен в этом окружении.'); return end
        if not alive or not state.hat then for _,o in ipairs(assets) do o:Destroy() end; return end
        local model=new('Model',{Name='TransparentChineseHat'},root)
        local parts={}
        for _,asset in ipairs(assets) do
            -- Strip scripts before parenting anything into the data model.
            for _,o in ipairs(asset:GetDescendants()) do if o:IsA('LuaSourceContainer') then o:Destroy() end end
            if asset:IsA('LuaSourceContainer') then asset:Destroy() else
                if asset:IsA('BasePart') then table.insert(parts,asset) end
                for _,o in ipairs(asset:GetDescendants()) do if o:IsA('BasePart') then table.insert(parts,o) end end
                asset.Parent=model
            end
        end
        if #parts==0 then model:Destroy(); notify('Ассет шляпы не содержит 3D-деталей.'); return end
        for _,part in ipairs(parts) do part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false; part.Transparency=hatTransparency; part.CastShadow=false end
        local cf,sz=model:GetBoundingBox()
        if sz.X>0 then pcall(function() model:ScaleTo(model:GetScale()*3.6/math.max(sz.X,sz.Z)) end) end
        cf,sz=model:GetBoundingBox()
        hatOffset=cf:ToObjectSpace(model:GetPivot())
        hat=model
        tintHat(hat)
    end)
end
toggle(characterPage,'Прозрачная китайская шляпа • на себя',false,function(on)
    state.hat=on
    if on then
        if not hatDrawingMode then loadHat() end
    else
        if hat then hat:Destroy(); hat=nil end
        for _,tri in ipairs(hatTriangles) do pcall(function() tri.Visible=false end) end
    end
end)
setDrawingToggle=toggle(characterPage,'Китайская шляпа • Drawing mode',false,function(on)
    if on then
        hatDrawingMode=createHatDrawing()
        if not hatDrawingMode then setDrawingToggle(false) end
    else
        hatDrawingMode=false; clearHatDrawing()
    end
    if not hatDrawingMode and state.hat and not hat then loadHat() end
end)
note(characterPage,'Drawing mode: геометрический конус без текстур, поверх сцены. Это альтернативная отрисовка, не копия Toolbox-меша. Включи также саму шляпу.')
local function updateHatDrawing(camera)
    if not hatDrawingMode then return end
    local visible=catalogRig or danceRig or me.Character
    local head=visible and visible:FindFirstChild('Head')
    if not state.hat or not head or hatTransparency>=1 then
        for _,tri in ipairs(hatTriangles) do tri.Visible=false end
        return
    end
    local frame=head.CFrame*CFrame.new(0,head.Size.Y/2+.12,0)
    local apex=frame*Vector3.new(0,.85,0)
    local faces={}
    for i=1,40 do
        local a=(i-1)*math.pi*2/40
        local b=i*math.pi*2/40
        local wa=frame*Vector3.new(math.cos(a)*1.8,0,math.sin(a)*1.8)
        local wb=frame*Vector3.new(math.cos(b)*1.8,0,math.sin(b)*1.8)
        -- Cull rear-facing surfaces to avoid stacking semi-transparent faces.
        local normal=(wb-apex):Cross(wa-apex)
        local facing=normal:Dot(camera.CFrame.Position-(apex+wa+wb)/3)>0
        local pa=camera:WorldToViewportPoint(apex)
        local pb=camera:WorldToViewportPoint(wa)
        local pc=camera:WorldToViewportPoint(wb)
        table.insert(faces,{a=pa,b=pb,c=pc,depth=(pa.Z+pb.Z+pc.Z)/3,
            visible=facing and pa.Z>.05 and pb.Z>.05 and pc.Z>.05})
    end
    table.sort(faces,function(a,b) return a.depth>b.depth end)
    for i,face in ipairs(faces) do
        local tri=hatTriangles[i]
        tri.Visible=face.visible
        if face.visible then
            tri.PointA=Vector2.new(face.a.X,face.a.Y)
            tri.PointB=Vector2.new(face.b.X,face.b.Y)
            tri.PointC=Vector2.new(face.c.X,face.c.Y)
            tri.Color=colors.hat
            -- Drawing alpha is inverse to Roblox Transparency.
            tri.Transparency=1-hatTransparency
        end
    end
end
toggle(characterPage,'Кольцо при прыжке • 3 секунды',false,function(on) state.jump=on end)
local function jumpRing(character)
    local r=character:FindFirstChild('HumanoidRootPart'); if not r then return end
    local model=new('Model',{Name='JumpRing'},root)
    local ray=RaycastParams.new(); ray.FilterType=Enum.RaycastFilterType.Exclude; ray.FilterDescendantsInstances={character,root}
    local hit=workspace:Raycast(r.Position,Vector3.new(0,-10,0),ray)
    local origin=hit and hit.Position+Vector3.new(0,.06,0) or r.Position-Vector3.new(0,3,0)
    for i=1,48 do
        local angle=2*math.pi*i/48
        local cf=CFrame.new(origin)*CFrame.Angles(0,angle,0)*CFrame.new(0,0,-2)
        local part=new('Part',{Size=Vector3.new(.28,.07,.11),CFrame=cf,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Material=Enum.Material.Neon,Color=pink,Transparency=.1},model)
        TweenService:Create(part,TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=1,CFrame=CFrame.new(origin)*CFrame.Angles(0,angle,0)*CFrame.new(0,0,-4),Size=Vector3.new(.54,.035,.08)}):Play()
    end
    Debris:AddItem(model,3)
end
note(espPage,'Список игроков проверяется через Roblox IsFriendsWith. ESP можно включить только подтверждённым друзьям.')
local chosenFriend=nil
local setFriendESP
local refreshFriends=dropdown(espPage,'Игроки',{},'Выбери игрока',function(p)
    chosenFriend=p
    if setFriendESP then setFriendESP(config(p).esp) end
    if not friends[p] then notify(friendStatus[p]=='checking' and 'Дружба ещё проверяется.' or 'Это не подтверждённый друг.') end
end)
setFriendESP=toggle(espPage,'ESP выбранного друга',false,function(on)
    if not chosenFriend or not friends[chosenFriend] then setFriendESP(false); notify('Сначала выбери подтверждённого друга.'); return end
    config(chosenFriend).esp=on; setEffect(chosenFriend,'esp',on)
end)
toggle(espPage,'Target ESP • ник, аватар, уголки',false,function(on) state.target=on end)
note(espPage,'На ПК — наведи курсор на персонажа. На сенсорном устройстве — наведи центр экрана. Угловая 2D-рамка без сплошных сторон.')
friendRefreshUI=function()
    local all,targets={},{{label='Я',value=me}}
    for _,p in ipairs(Players:GetPlayers()) do if p~=me then
        local suffix=({friend='♥ друг',other='не друг',checking='проверка…',unknown='нет данных'})[friendStatus[p]] or 'проверка…'
        table.insert(all,{label=p.DisplayName..' (@'..p.Name..') • '..suffix,value=p})
        if friends[p] then table.insert(targets,{label=p.DisplayName..' (@'..p.Name..')',value=p}) end
    end end
    refreshTargets(targets); refreshFriends(all)
end
connect(button(espPage,'Обновить анализ друзей').Activated,function() for _,p in ipairs(Players:GetPlayers()) do if p~=me then scan(p) end end end)
local targetCard=new('Frame',{Size=UDim2.fromOffset(240,64),AnchorPoint=Vector2.new(.5,0),BackgroundColor3=Color3.fromRGB(28,22,36),BackgroundTransparency=.1,Visible=false},gui); round(targetCard,12)
local avatar=new('ImageLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(7,7),Size=UDim2.fromOffset(50,50)},targetCard); round(avatar,10)
local targetName=text(targetCard,'',13,UDim2.fromOffset(67,9),UDim2.fromOffset(167,24)); targetName.TextTruncate=Enum.TextTruncate.AtEnd; targetName:SetAttribute('SakuraNoTranslate',true)
local targetUser=text(targetCard,'',11,UDim2.fromOffset(67,33),UDim2.fromOffset(167,18)); targetUser.TextColor3=muted; targetUser.TextTruncate=Enum.TextTruncate.AtEnd; targetUser:SetAttribute('SakuraNoTranslate',true)
local box=new('Frame',{BackgroundTransparency=1,Visible=false},gui)
for _,pos in ipairs({{0,0},{1,0},{0,1},{1,1}}) do
    local x,y=pos[1],pos[2]
    new('Frame',{AnchorPoint=Vector2.new(x,y),Position=UDim2.fromScale(x,y),Size=UDim2.new(.23,0,0,2),BackgroundColor3=colors.target,BorderSizePixel=0},box)
    new('Frame',{AnchorPoint=Vector2.new(x,y),Position=UDim2.fromScale(x,y),Size=UDim2.new(0,2,.18,0),BackgroundColor3=colors.target,BorderSizePixel=0},box)
end
checkpoint('цвета')
-- All five colors are independent. Trail/cape/friend ESP colors apply to
-- every enabled recipient, and are reused when characters respawn.
local targetStroke=new('UIStroke',{Color=colors.target,Transparency=.4,Thickness=1},targetCard)
targetName.TextColor3=colors.target
local function recolor(key,c)
    colors[key]=c
    if key=='guestSkin' or key=='guestHighlight' then
        if guestColorChanged then guestColorChanged(key,c) end
    elseif key=='custom' then if customColorChanged then customColorChanged(c) end
    elseif key=='hat' then customHatColor=true; tintHat(hat)
    elseif key=='target' then
        for _,o in ipairs(box:GetChildren()) do if o:IsA('Frame') then o.BackgroundColor3=c end end
        targetName.TextColor3=c; targetStroke.Color=c
    else
        for _,entries in pairs(effects) do
            local e=entries[key]
            if e then
                if key=='cape' then capeFX.refresh()
                else
                    for _,o in ipairs(e.objects) do
                        if o:IsA('Trail') then o.Color=ColorSequence.new(c,c:Lerp(Color3.new(1,1,1),.35))
                        elseif o:IsA('ParticleEmitter') then o.Color=trailFX.particleColor(o.Name,c)
                        elseif o:IsA('PointLight') then o.Color=c
                        elseif o:IsA('Highlight') then o.FillColor=c; o.OutlineColor=c
                        elseif o:IsA('BillboardGui') then
                            for _,l in ipairs(o:GetDescendants()) do if l:IsA('TextLabel') then l.TextColor3=c end end
                        end
                    end
                end
            end
        end
    end
    -- Live MM2 gun highlights are not part of the trail/cape/ESP effect list.
    if mm2ColorChanged then mm2ColorChanged(key,c) end
end
note(colorPage,'Независимые цвета • палитра, RGB и HEX. Цвет трейла, плаща и Friend ESP применяется ко всем включённым получателям. Если на плаще картинка, цвет подкрашивает её; белый фон включается во вкладке «Персонаж».')
note(colorPage,'Цвет всей шляпы: текстуры и старые материалы убираются, Union-детали перекрашиваются. Прозрачность настраивается во вкладке «Персонаж».')
local palette={pink,Color3.fromRGB(255,75,95),Color3.fromRGB(255,157,66),Color3.fromRGB(255,224,87),Color3.fromRGB(93,233,150),Color3.fromRGB(89,219,255),Color3.fromRGB(107,144,255),Color3.fromRGB(185,112,255),Color3.new(1,1,1),Color3.fromRGB(30,30,38)}
local colorPickerRefresh={}
local function colorPicker(key,title)
    local wrap=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,36),AutomaticSize=Enum.AutomaticSize.Y},colorPage)
    new('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},wrap)
    local header=button(wrap,title..'  ▾')
    local preview=new('Frame',{Size=UDim2.fromOffset(22,22),Position=UDim2.new(1,-31,.5,-11),BackgroundColor3=colors[key],BorderSizePixel=0},header); round(preview,6)
    local body=new('Frame',{BackgroundColor3=Color3.fromRGB(30,24,39),BorderSizePixel=0,Size=UDim2.new(1,0,0,226),Visible=false},wrap); round(body,10)
    connect(header.Activated,function() body.Visible=not body.Visible end)
    local swatches=new('Frame',{BackgroundTransparency=1,Position=UDim2.fromOffset(12,12),Size=UDim2.new(1,-24,0,28)},body)
    new('UIGridLayout',{CellSize=UDim2.new(.1,-4,1,0),CellPadding=UDim2.fromOffset(4,0),SortOrder=Enum.SortOrder.LayoutOrder},swatches)
    local hex=new('TextBox',{Text='',PlaceholderText='#FF97C1',ClearTextOnFocus=false,Font=Enum.Font.Code,TextSize=14,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(46,36,57),BorderSizePixel=0,Position=UDim2.fromOffset(12,177),Size=UDim2.new(.55,-18,0,34)},body); round(hex,7)
    local apply=button(body,'Применить HEX',UDim2.new(.45,-18,0,34),UDim2.new(.55,6,0,177))
    local fills,knobs,labels={},{},{}
    local function rgb(c) return {math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5)} end
    local function draw()
        local channels=rgb(colors[key]); preview.BackgroundColor3=colors[key]
        hex.Text=string.format('#%02X%02X%02X',channels[1],channels[2],channels[3])
        for i=1,3 do
            if fills[i] then
                fills[i].Size=UDim2.fromScale(channels[i]/255,1)
                knobs[i].Position=UDim2.fromScale(channels[i]/255,.5)
                labels[i].Text=({'R','G','B'})[i]..'  '..channels[i]
            end
        end
    end
    local function set(c) recolor(key,c); draw() end
    for _,c in ipairs(palette) do
        local sw=button(swatches,'',UDim2.fromOffset(25,25)); sw.BackgroundColor3=c
        connect(sw.Activated,function() set(c) end)
    end
    for i=1,3 do
        local y=49+(i-1)*40
        labels[i]=text(body,'',12,UDim2.fromOffset(12,y+5),UDim2.fromOffset(57,22))
        local area=new('TextButton',{Text='',AutoButtonColor=false,BackgroundTransparency=1,Position=UDim2.fromOffset(77,y),Size=UDim2.new(1,-95,0,34)},body)
        local track=new('Frame',{Active=false,BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(62,51,73),Position=UDim2.new(0,0,.5,-4),Size=UDim2.new(1,0,0,8)},area); round(track,4)
        fills[i]=new('Frame',{BorderSizePixel=0,BackgroundColor3=({Color3.fromRGB(255,107,134),Color3.fromRGB(117,231,160),Color3.fromRGB(116,173,255)})[i],Size=UDim2.fromScale(0,1)},track); round(fills[i],4)
        knobs[i]=new('Frame',{AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(16,16),BackgroundColor3=Color3.fromRGB(250,243,255),BorderSizePixel=0},track); round(knobs[i],8)
        local drag=nil
        local function update(x)
            local channels=rgb(colors[key])
            channels[i]=math.floor(math.clamp((x-area.AbsolutePosition.X)/math.max(1,area.AbsoluteSize.X),0,1)*255+.5)
            set(Color3.fromRGB(channels[1],channels[2],channels[3]))
        end
        connect(area.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                drag=input; colorPage.ScrollingEnabled=false; update(input.Position.X)
            end
        end)
        connect(UIS.InputChanged,function(input)
            if drag and (input==drag or (drag.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)) then update(input.Position.X) end
        end)
        connect(UIS.InputEnded,function(input)
            if drag and (input==drag or (drag.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)) then drag=nil; colorPage.ScrollingEnabled=true end
        end)
        connect(UIS.WindowFocusReleased,function() drag=nil; colorPage.ScrollingEnabled=true end)
    end
    local function parseHex()
        local value=hex.Text:gsub('%s',''):gsub('^#','')
        if #value==3 and value:match('^%x+$') then value=value:gsub('(.)','%1%1') end
        if #value~=6 or not value:match('^%x+$') then notify('HEX: введи #FF97C1 или #F9C'); draw(); return end
        set(Color3.fromRGB(tonumber(value:sub(1,2),16),tonumber(value:sub(3,4),16),tonumber(value:sub(5,6),16)))
    end
    connect(apply.Activated,parseHex)
    connect(hex.FocusLost,function(enterPressed) if enterPressed then parseHex() end end)
    colorPickerRefresh[key]=draw
    draw()
end
colorPicker('hat','Китайская шляпа')
colorPicker('trail','Трейл')
colorPicker('cape','Плащ • 16 слоёв')
colorPicker('esp','Friend ESP')
colorPicker('target','Target ESP • рамка и ник')
colorPicker('custom','Кастомный игрок • Highlight')
colorPicker('guestSkin','Клон-гость • цвет тела')
colorPicker('guestHighlight','Клон-гость • Highlight')
local thumbs={}
local currentTarget
local function updateTarget(camera)
    box.Visible=false; targetCard.Visible=false
    if not state.target then currentTarget=nil; return end
    local point=UIS.TouchEnabled and not UIS.MouseEnabled and camera.ViewportSize/2 or UIS:GetMouseLocation()
    local ray=camera:ViewportPointToRay(point.X,point.Y)
    local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={me.Character or root,root}
    local result=workspace:Raycast(ray.Origin,ray.Direction*1500,params)
    local hit=result and result.Instance
    local p
    while hit and hit~=workspace do
        if hit:IsA('Model') then p=Players:GetPlayerFromCharacter(hit); if p then break end end
        hit=hit.Parent
    end
    if not p or p==me or not p.Character then currentTarget=nil; return end
    if currentTarget~=p then
        currentTarget=p; targetName.Text=p.DisplayName; targetUser.Text='@'..p.Name
        avatar.Image=thumbs[p.UserId] or ''
        if not thumbs[p.UserId] then
            task.spawn(function()
                local success,url=pcall(function() return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
                if success and alive then thumbs[p.UserId]=url; if currentTarget==p then avatar.Image=url end end
            end)
        end
    end
    local cf,size=p.Character:GetBoundingBox()
    local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
    for x=-1,1,2 do for y=-1,1,2 do for z=-1,1,2 do
        local v=camera:WorldToViewportPoint(cf*Vector3.new(size.X*x/2,size.Y*y/2,size.Z*z/2))
        if v.Z<=0 then return end
        minX=math.min(minX,v.X); minY=math.min(minY,v.Y); maxX=math.max(maxX,v.X); maxY=math.max(maxY,v.Y)
    end end end
    local inset=game:GetService('GuiService'):GetGuiInset()
    local viewport=camera.ViewportSize
    minX=math.clamp(minX,0,viewport.X); maxX=math.clamp(maxX,0,viewport.X)
    minY=math.clamp(minY,0,viewport.Y); maxY=math.clamp(maxY,0,viewport.Y)
    box.Position=UDim2.fromOffset(minX-inset.X,minY-inset.Y); box.Size=UDim2.fromOffset(maxX-minX,maxY-minY); box.Visible=true
    targetCard.Position=UDim2.fromOffset(math.clamp((minX+maxX)/2,120,math.max(120,viewport.X-120))-inset.X,math.max(0,minY-inset.Y-72)); targetCard.Visible=true
end
note(worldPage,'Погода, небо и время меняются только у тебя. Капли и снег появляются вокруг камеры, под крышей эмиссия останавливается.')
dropdown(worldPage,'Время',{'Исходное','Утро','День','Закат','Ночь'},'Исходное',function(v)
    Lighting.ClockTime=({['Утро']=7,['День']=14,['Закат']=18.2,['Ночь']=0})[v] or original.ClockTime
end)
local skies={
    ['Сакура / розовое']={'271042516','271077243','271042556','271042310','271042467','271077958'},
    ['Космос']={'159454299','159454296','159454293','159454286','159454300','159454288'}
}
checkpoint('небо')
-- Built-in Roblox texture set for the clear sky.
local clearSky={'rbxasset://textures/sky/sky512_bk.tex','rbxasset://textures/sky/sky512_dn.tex','rbxasset://textures/sky/sky512_ft.tex','rbxasset://textures/sky/sky512_lf.tex','rbxasset://textures/sky/sky512_rt.tex','rbxasset://textures/sky/sky512_up.tex'}
local function restoreSky()
    if ownedSky then ownedSky:Destroy(); ownedSky=nil end
    if originalSky then pcall(function() originalSky.Parent=Lighting end) end
end
dropdown(worldPage,'Скайбокс',{'Исходный','Сакура / розовое','Космос','Ясное небо'},'Исходный',function(v)
    restoreSky(); if v=='Исходный' then return end
    if originalSky then originalSky.Parent=nil end
    ownedSky=new('Sky',{Name='SakuraSky'},Lighting)
    for i,k in ipairs({'SkyboxBk','SkyboxDn','SkyboxFt','SkyboxLf','SkyboxRt','SkyboxUp'}) do ownedSky[k]=v=='Ясное небо' and clearSky[i] or 'rbxassetid://'..skies[v][i] end
    ownedSky.StarCount=v=='Космос' and 3000 or 1000
end)
checkpoint('погода')
-- Weather. Roblox limits one ParticleEmitter to about 400 particles/s (about
-- 100/s on mobile) and Squash<0 flattens particles instead of stretching them,
-- so the old single emitter over a 70x70 area produced nearly invisible slivers.
-- Now several emitters share a compact volume right above the camera (dense and
-- visible), a wide far layer adds depth, and drops are stretched along velocity.
-- One table keeps the main chunk under Luau's local-variable limit.
local weather={everywhere=false,emitters={rain={},snow={}},caption=nil}
do
    local mobileDevice=UIS.TouchEnabled and not UIS.MouseEnabled
    local nearSpan=mobileDevice and 22 or 34
    weather.near=new('Part',{Name='WeatherNear',Size=Vector3.new(nearSpan,1,nearSpan),Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,Transparency=1},root)
    weather.far=new('Part',{Name='WeatherFar',Size=Vector3.new(120,1,120),Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,Transparency=1},root)
    local texture='rbxasset://textures/particles/sparkles_main.dds'
    local function emitter(kind,parent,props)
        props.Enabled=false; props.Texture=texture
        local e=new('ParticleEmitter',props,parent)
        pcall(function() e.Brightness=kind=='snow' and 1.5 or 1.25 end)
        table.insert(weather.emitters[kind],e); return e
    end
    local rainColor=ColorSequence.new(Color3.fromRGB(200,226,252))
    local snowColor=ColorSequence.new(Color3.fromRGB(246,249,255))
    for i=1,3 do
        emitter('rain',weather.near,{Name='Rain'..i,Rate=400,Lifetime=NumberRange.new(.5,.8),Speed=NumberRange.new(75,100),Acceleration=Vector3.new(0,-40,0),EmissionDirection=Enum.NormalId.Bottom,SpreadAngle=Vector2.new(1.5,1.5),Size=NumberSequence.new(.24),Squash=NumberSequence.new(3),Color=rainColor,Transparency=NumberSequence.new(.32),Orientation=Enum.ParticleOrientation.VelocityParallel,LightEmission=.45,LightInfluence=.35,ZOffset=i*.01})
    end
    emitter('rain',weather.far,{Name='RainFar',Rate=400,Lifetime=NumberRange.new(1,1.5),Speed=NumberRange.new(70,90),Acceleration=Vector3.new(0,-30,0),EmissionDirection=Enum.NormalId.Bottom,SpreadAngle=Vector2.new(1,1),Size=NumberSequence.new(.42),Squash=NumberSequence.new(3.5),Color=rainColor,Transparency=NumberSequence.new(.55),Orientation=Enum.ParticleOrientation.VelocityParallel,LightEmission=.4,LightInfluence=.35})
    local flake=NumberSequence.new({NumberSequenceKeypoint.new(0,.12),NumberSequenceKeypoint.new(.3,.3),NumberSequenceKeypoint.new(1,.1)})
    for i=1,3 do
        emitter('snow',weather.near,{Name='Snow'..i,Rate=260,Lifetime=NumberRange.new(5,8),Speed=NumberRange.new(6,10),Acceleration=Vector3.new(1.1,-.6,.5),EmissionDirection=Enum.NormalId.Bottom,SpreadAngle=Vector2.new(25,25),Size=flake,Color=snowColor,Transparency=NumberSequence.new(.1),RotSpeed=NumberRange.new(-70,70),Rotation=NumberRange.new(0,360),LightEmission=.5,LightInfluence=.4,ZOffset=i*.01})
    end
    emitter('snow',weather.far,{Name='SnowFar',Rate=400,Lifetime=NumberRange.new(6,9),Speed=NumberRange.new(8,12),Acceleration=Vector3.new(1,-.5,.4),EmissionDirection=Enum.NormalId.Bottom,SpreadAngle=Vector2.new(15,15),Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.3),NumberSequenceKeypoint.new(.4,.5),NumberSequenceKeypoint.new(1,.2)}),Color=snowColor,Transparency=NumberSequence.new(.25),RotSpeed=NumberRange.new(-40,40),LightEmission=.45,LightInfluence=.4})
    function weather.set(kind,on,clear)
        for _,e in ipairs(weather.emitters[kind]) do
            if e.Enabled~=on then e.Enabled=on end
            if clear then e:Clear() end
        end
    end
    local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
    -- Terrain and solid opaque parts count as a roof; invisible walls, triggers
    -- and decorative non-collidable parts do not, so weather is not silently
    -- disabled by a map's invisible ceiling.
    function weather.blocked(camera,eye)
        if weather.everywhere then return false end
        local filter={root,camera,me.Character or root}
        for _=1,6 do
            params.FilterDescendantsInstances=filter
            local hit=workspace:Raycast(eye,Vector3.new(0,55,0),params)
            if not hit then return false end
            local part=hit.Instance
            if part:IsA('Terrain') or (part.CanCollide and part.Transparency<.9) then return true end
            table.insert(filter,part)
        end
        return true
    end
    function weather.update(camera,eye)
        local wantRain,wantSnow=state.rain,state.snow
        local roof=false
        if wantRain or wantSnow then
            local ok,result=pcall(weather.blocked,camera,eye)
            roof=ok and result or false
        end
        weather.set('rain',wantRain and not roof); weather.set('snow',wantSnow and not roof)
        local caption=(not wantRain and not wantSnow) and 'Погода: выключена' or roof and 'Погода: пауза под крышей. Если крыши нет — включи «Погода везде».' or 'Погода: идёт'
        if caption~=weather.caption then weather.caption=caption; weather.status.Text=caption end
    end
end
toggle(worldPage,'Дождь • капли',false,function(on) state.rain=on; if not on then weather.set('rain',false,true) end end)
toggle(worldPage,'Зима • снег',false,function(on) state.snow=on; if not on then weather.set('snow',false,true) end end)
toggle(worldPage,'Погода везде • не проверять крышу',false,function(on) weather.everywhere=on end)
weather.status=note(worldPage,'Погода: выключена')
note(worldPage,'Дождь и снег: несколько эмиттеров вокруг камеры, до 400 частиц/с на эмиттер (на телефоне меньше). Лучше всего видно на графике 5+.')
local fogBloom=new('BloomEffect',{Name='SakuraFogGlow',Enabled=false,Intensity=.7,Size=38,Threshold=.7},Lighting)
local function applyFog()
    if state.fog then
        for _,o in ipairs(Lighting:GetChildren()) do if o:IsA('Atmosphere') then table.insert(hiddenAtmospheres,o); o.Parent=nil end end
        Lighting.FogStart=state.lightFog and 70 or 5; Lighting.FogEnd=state.lightFog and 650 or 155
        Lighting.FogColor=state.glow and Color3.fromRGB(246,207,236) or Color3.fromRGB(188,198,215)
    else
        Lighting.FogStart=original.FogStart; Lighting.FogEnd=original.FogEnd; Lighting.FogColor=original.FogColor
        for _,o in ipairs(hiddenAtmospheres) do pcall(function() o.Parent=Lighting end) end; hiddenAtmospheres={}
    end
    fogBloom.Enabled=state.fog and state.glow
end
toggle(worldPage,'Туман',false,function(on) state.fog=on; applyFog() end)
toggle(worldPage,'Прозрачный / лёгкий туман',false,function(on) state.lightFog=on; applyFog() end)
toggle(worldPage,'Свечение тумана',false,function(on) state.glow=on; applyFog() end)
note(shaderPage,'Это пресеты Roblox Lighting и постобработки, не внешние GPU-шейдеры. На низком качестве графики часть эффектов может быть незаметна.')
local function applyShader(name)
    for _,o in ipairs(shaderObjects) do o:Destroy() end; shaderObjects={}
    for _,k in ipairs({'Brightness','Ambient','OutdoorAmbient','ExposureCompensation','ColorShift_Top','GlobalShadows'}) do Lighting[k]=original[k] end
    if name=='Без пресета' then return end
    local presets={
        ['Sakura soft']={Color3.fromRGB(255,220,238),.06,.08,.04,.25},
        ['Cinematic']={Color3.fromRGB(228,236,255),-.03,.23,-.15,.18},
        ['Golden hour']={Color3.fromRGB(255,224,180),.04,.12,.12,.4},
        ['Cold winter']={Color3.fromRGB(203,225,255),.03,.13,-.2,.22},
        ['Vivid']={Color3.fromRGB(255,249,243),.02,.15,.3,.3},
        ['Dream bloom']={Color3.fromRGB(244,216,255),.06,.02,.04,1.1}
    }
    local p=presets[name]; if not p then return end
    table.insert(shaderObjects,new('ColorCorrectionEffect',{Name='SakuraGrade',TintColor=p[1],Brightness=p[2],Contrast=p[3],Saturation=p[4]},Lighting))
    table.insert(shaderObjects,new('BloomEffect',{Name='SakuraBloom',Intensity=p[5],Size=30,Threshold=.9},Lighting))
    table.insert(shaderObjects,new('SunRaysEffect',{Name='SakuraRays',Intensity=.06,Spread=.75},Lighting))
    Lighting.GlobalShadows=true
end
dropdown(shaderPage,'Пресет',{'Без пресета','Sakura soft','Cinematic','Golden hour','Cold winter','Vivid','Dream bloom'},'Без пресета',applyShader)
note(settingsPage,'Меню: верхняя кнопка или RightShift. Размер автоматически подстраивается под экран. Друзей можно выбрать только среди игроков текущего сервера.')
note(settingsPage,'Удаление выключает эффекты, удаляет интерфейс и возвращает сохранённое освещение. Изменения Lighting другими скриптами игры могут перезаписывать пресеты.')
note(settingsPage,'Язык интерфейса')
local languageRow=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,36)},settingsPage)
local russianButton=button(languageRow,'Русский',UDim2.new(.5,-4,1,0))
local englishButton=button(languageRow,'English',UDim2.new(.5,-4,1,0),UDim2.new(.5,4,0,0))
russianButton:SetAttribute('SakuraNoTranslate',true); englishButton:SetAttribute('SakuraNoTranslate',true)
local function updateLanguageButtons()
    russianButton.TextColor3=interfaceLanguage=='ru' and pink or muted
    englishButton.TextColor3=interfaceLanguage=='en' and pink or muted
end
connect(russianButton.Activated,function() setInterfaceLanguage('ru'); updateLanguageButtons() end)
connect(englishButton.Activated,function() setInterfaceLanguage('en'); updateLanguageButtons() end)
updateLanguageButtons()
note(settingsPage,'Переключение применяется сразу. Выбор сохраняется до закрытия сессии инжектора.')

local function cleanup()
    if not alive then return end; alive=false
    for _,c in ipairs(connections) do c:Disconnect() end
    for p,entries in pairs(effects) do for key in pairs(entries) do destroyEffect(p,key) end end
    for _,o in ipairs(shaderObjects) do o:Destroy() end
    fogBloom:Destroy()
    clearHatDrawing()
    for _,o in ipairs(hiddenAtmospheres) do pcall(function() o.Parent=Lighting end) end
    restoreSky()
    for k,v in pairs(original) do pcall(function() Lighting[k]=v end) end
    if customCleanup then customCleanup() end
    root:Destroy(); gui:Destroy()
    if env.SakuraVisualsCleanup==cleanup then env.SakuraVisualsCleanup=nil end
end
env.SakuraVisualsCleanup=cleanup
do
    -- Self-check: shows what loaded and what the executor does not support.
    local reportNote=note(settingsPage,'Проверка функций: нажми кнопку ниже — отчёт появится здесь и в консоли (print).')
    reportNote:SetAttribute('SakuraNoTranslate',true)
    connect(button(settingsPage,'Проверка функций • что загружено').Activated,function()
        reportNote.Text=loadState.report()
        notify('Отчёт готов: список ниже и в консоли (print).')
    end)
end
connect(button(settingsPage,'Удалить sakuravisuals / восстановить мир').Activated,cleanup)
connect(UIS.InputBegan,function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.RightShift then window.Visible=not window.Visible end end)
local function watchCharacter(p,c)
    task.spawn(function()
        local r=c:WaitForChild('HumanoidRootPart',10)
        local h=c:WaitForChild('Humanoid',10)
        if not alive or p.Character~=c or not r then return end
        for _,key in ipairs({'trail','cape','esp'}) do setEffect(p,key,config(p)[key]) end
        if p==me and h then
            connect(h.Died,function()
                for _,reset in pairs(respawnHooks) do pcall(reset) end
            end)
            connect(h.StateChanged,function(_,s) if state.jump and s==Enum.HumanoidStateType.Jumping then jumpRing(c) end end)
        end
    end)
end
local function watchPlayer(p)
    if p~=me then scan(p) end
    connect(p.CharacterAdded,function(c) watchCharacter(p,c) end)
    connect(p.CharacterRemoving,function() for _,key in ipairs({'trail','cape','esp'}) do destroyEffect(p,key) end end)
    if p.Character then watchCharacter(p,p.Character) end
end
for _,p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
connect(Players.PlayerAdded,function(p) watchPlayer(p); friendRefreshUI() end)
connect(Players.PlayerRemoving,function(p)
    for _,key in ipairs({'trail','cape','esp'}) do destroyEffect(p,key) end
    wanted[p]=nil; effects[p]=nil; friends[p]=nil; friendStatus[p]=nil
    if selected==p then selected=me; setTrail(config(me).trail); setCape(config(me).cape) end
    if chosenFriend==p then chosenFriend=nil; setFriendESP(false) end
    task.defer(function() if alive then friendRefreshUI() end end)
end)
connect(me.CharacterRemoving,function()
    for _,reset in pairs(respawnHooks) do pcall(reset) end
end)
friendRefreshUI()
checkpoint('кастомный игрок')
-- Custom player: adjustable transparency (70% default) with Highlight.
-- Only an equipped replacement model hides the original avatar completely.
local customOn=false
local customTransparency=.70
local spinOn,spinAngle,spinSpeed=false,0,360
local spinModel=nil
local spinParts={}
local hiddenCharacter=nil
local hiddenProperties={}
local ghost=nil
local ghostHighlight=nil
local equipped=nil
local library={}
local loadingModel=false
local modelScale=1
local modelYaw=0
local function bodyComplete(character)
    if not character then return false end
    local h=character:FindFirstChildOfClass('Humanoid')
    if not h or h.Health<=0 or not character:FindFirstChild('HumanoidRootPart') then return false end
    local names=h.RigType==Enum.HumanoidRigType.R15
        and {'Head','UpperTorso','LowerTorso','LeftUpperArm','LeftLowerArm','LeftHand',
            'RightUpperArm','RightLowerArm','RightHand','LeftUpperLeg','LeftLowerLeg','LeftFoot',
            'RightUpperLeg','RightLowerLeg','RightFoot'}
        or {'Head','Torso','Left Arm','Right Arm','Left Leg','Right Leg'}
    for _,name in ipairs(names) do
        local part=character:FindFirstChild(name)
        if not part or not part:IsA('BasePart') then return false end
    end
    return true
end
local function restoreCharacter()
    for o,entry in pairs(hiddenProperties) do
        pcall(function()
            o.Transparency=entry.transparency
            if entry.ltm~=nil then o.LocalTransparencyModifier=entry.ltm end
        end)
    end
    hiddenProperties={}; hiddenCharacter=nil
end
local function removeGhost()
    if ghost then ghost:Destroy() end
    ghost=nil; ghostHighlight=nil
end
local function cleanPart(source)
    local wasArchivable=source.Archivable
    source.Archivable=true
    local success,part=pcall(function() return source:Clone() end)
    source.Archivable=wasArchivable
    if not success or not part then return nil end
    -- Geometry only. Never insert executable or interactive asset contents.
    for _,o in ipairs(part:GetChildren()) do
        if not o:IsA('DataModelMesh') and not o:IsA('SurfaceAppearance') and not o:IsA('Decal') and not o:IsA('Texture') then o:Destroy() end
    end
    for _,o in ipairs(part:GetDescendants()) do
        if o:IsA('LuaSourceContainer') then o:Destroy() end
    end
    part.Anchored=true; part.CanCollide=false; part.CanTouch=false
    part.CanQuery=false; part.CastShadow=false
    part.LocalTransparencyModifier=0
    return part
end
local function removeSpin()
    if spinModel then spinModel:Destroy() end
    spinModel=nil; spinParts={}
end
local function refreshSpin(c)
    if not spinOn or equipped or danceRig or catalogRig or not c then removeSpin(); return end
    if not spinModel then
        spinModel=new('Model',{Name='SakuraVisualSpin'},root)
        for _,o in ipairs(c:GetChildren()) do
            if o:IsA('Shirt') or o:IsA('Pants') or o:IsA('ShirtGraphic') or o:IsA('BodyColors') then
                local copy=o:Clone(); if copy then copy.Parent=spinModel end
            end
        end
        new('Humanoid',{DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None,
            RequiresNeck=false,BreakJointsOnDeath=false,AutoRotate=false},spinModel)
    end
    for source,entry in pairs(spinParts) do
        if not source:IsDescendantOf(c) then entry.part:Destroy(); spinParts[source]=nil end
    end
    for _,source in ipairs(c:GetDescendants()) do
        if source:IsA('BasePart') and source.Name~='HumanoidRootPart' and not spinParts[source]
            and not source:FindFirstAncestorOfClass('Tool') then
            local saved=hiddenProperties[source]
            local original=saved and saved.transparency or source.Transparency
            if original<1 then
                local part=cleanPart(source)
                if part then
                    local decals={}
                    for _,decal in ipairs(part:GetChildren()) do
                        if decal:IsA('Decal') then
                            local src=source:FindFirstChild(decal.Name)
                            local data=src and hiddenProperties[src]
                            decals[decal]=data and data.transparency or decal.Transparency
                        end
                    end
                    part.Transparency=original; part.CFrame=source.CFrame; part.Parent=spinModel
                    spinParts[source]={part=part,transparency=original,decals=decals}
                end
            end
        end
    end
end
local function refreshGhost(c)
    if not customOn or not c then removeGhost(); return end
    if not ghost then
        ghost=new('Folder',{Name='CustomPlayer_Highlight'},root)
        ghostHighlight=new('Highlight',{Adornee=c,FillColor=colors.custom,
            OutlineColor=colors.custom,FillTransparency=.65,OutlineTransparency=0,
            DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},ghost)
    end
    ghostHighlight.Adornee=catalogRig or danceRig or (equipped and equipped.model) or spinModel or c
end
customColorChanged=function(c)
    if ghostHighlight then ghostHighlight.FillColor=c; ghostHighlight.OutlineColor=c end
end
note(customPage,'По умолчанию прозрачность 70%. Настрой её ниже: 0% — непрозрачный, 100% — невидимый. На 100% Highlight может исчезать.')
toggle(customPage,'Кастомный игрок • прозрачность + Highlight',false,function(on)
    customOn=on
    if not on then removeGhost(); if not equipped and not spinOn and not danceRig and not catalogRig then restoreCharacter() end end
end)
numberSlider(characterPage,'Прозрачность китайской шляпы',0,100,55,'%',function(v)
    hatTransparency=v/100
    if hat then tintHat(hat) end
end)
connect(button(characterPage,'Китайская шляпа • чистый белый #FFFFFF').Activated,function()
    recolor('hat',Color3.new(1,1,1))
    if colorPickerRefresh.hat then colorPickerRefresh.hat() end
end)
numberSlider(customPage,'Прозрачность персонажа',0,100,70,'%',function(v) customTransparency=v/100 end)
toggle(customPage,'Спинбот • только визуальный',false,function(on)
    spinOn=on
    if not on then
        spinAngle=0; removeSpin()
        if not customOn and not equipped and not danceRig and not catalogRig then restoreCharacter() end
    end
end)
numberSlider(customPage,'Скорость вращения (°/сек)',0,1080,360,'',function(v) spinSpeed=v end)
note(customPage,'Спинбот вращает только локальную копию или надетую модельку. Физический персонаж, управление и камера не вращаются.')
connect(button(customPage,'Изменить цвет Highlight → Цвета').Activated,function()
    selectPage(colorPage)
end)
note(customPage,'Цвета → «Кастомный игрок • Highlight». Работает после респавна. Обычные ESP и шляпа настраиваются независимо.')
note(modelsPage,'Введи ID модели из Creator Store, нажми «Добавить», затем выбери карточку. Модель — статичная оболочка: следует за тобой, но без собственной анимации и скриптов.')
local inputRow=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)},modelsPage)
local modelInput=new('TextBox',{PlaceholderText='Asset ID модели',Text='',ClearTextOnFocus=false,
    Font=Enum.Font.Code,TextSize=14,TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(43,35,54),
    BorderSizePixel=0,Size=UDim2.new(.68,-6,1,0)},inputRow); round(modelInput,8)
local addModel=button(inputRow,'Добавить',UDim2.new(.32,0,1,0),UDim2.fromScale(.68,0))
local modelStatus=note(modelsPage,'Выбрано: нет модели')
local function updateCards()
    for _,entry in pairs(library) do
        entry.card.Text=(equipped==entry and '● СНЯТЬ  •  ' or 'ВЫБРАТЬ  •  ')..entry.name..'  ['..entry.id..']'
        entry.card.TextColor3=equipped==entry and pink or Color3.fromRGB(239,231,247)
    end
    modelStatus.Text=equipped and ('Выбрано: '..equipped.name..' • '..equipped.id) or 'Выбрано: нет модели'
end
local function equip(entry)
    if equipped then equipped.model.Parent=nil end
    if equipped==entry then equipped=nil else equipped=entry end
    if equipped then
        local r=charRoot(me)
        equipped.model:PivotTo(r and r.CFrame or CFrame.new(0,-10000,0))
        equipped.model.Parent=root
    elseif not customOn and not spinOn and not danceRig and not catalogRig then restoreCharacter() end
    updateCards()
end
connect(button(modelsPage,'Снять модель / вернуть аватар').Activated,function() equip(nil) end)
local function adjustScale()
    if equipped then
        pcall(function() equipped.model:ScaleTo(equipped.baseScale*modelScale) end)
    end
end
local scaleRow=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,34)},modelsPage)
local smaller=button(scaleRow,'Размер −',UDim2.new(.32,0,1,0))
local scaleLabel=text(scaleRow,'1.0×',13,UDim2.fromScale(.34,0),UDim2.new(.3,0,1,0)); scaleLabel.TextXAlignment=Enum.TextXAlignment.Center
local bigger=button(scaleRow,'Размер +',UDim2.new(.32,0,1,0),UDim2.fromScale(.68,0))
connect(smaller.Activated,function() modelScale=math.max(.2,modelScale-.1); scaleLabel.Text=string.format('%.1f×',modelScale); adjustScale() end)
connect(bigger.Activated,function() modelScale=math.min(3,modelScale+.1); scaleLabel.Text=string.format('%.1f×',modelScale); adjustScale() end)
connect(button(modelsPage,'Повернуть модель на 90°').Activated,function() modelYaw=(modelYaw+90)%360 end)
local cards=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},modelsPage)
new('UIListLayout',{Padding=UDim.new(0,7)},cards)
local function importModel()
    if loadingModel then notify('Дождись окончания загрузки модели.'); return end
    local raw=modelInput.Text:match('^%s*(.-)%s*$')
    local id=raw:match('^(%d+)$') or raw:match('/asset/(%d+)') or raw:match('/library/(%d+)') or raw:match('[?&]id=(%d+)')
    if not id or #id>16 or not tonumber(id) or tonumber(id)<=0 then notify('Введи числовой Asset ID модели из Creator Store.'); return end
    if library[id] then notify('Модель уже добавлена — нажми её карточку.'); return end
    local count=0; for _ in pairs(library) do count+=1 end
    if count>=8 then notify('Лимит: 8 моделей за запуск, чтобы не перегружать устройство.'); return end
    loadingModel=true; addModel.Text='Загрузка…'
    task.spawn(function()
        local success,assets=pcall(function() return game:GetObjects('rbxassetid://'..id) end)
        if not alive then
            if success and type(assets)=='table' then for _,o in ipairs(assets) do o:Destroy() end end
            return
        end
        local model=Instance.new('Model'); model.Name='CustomModel_'..id
        local name='Модель'; local partCount=0
        local loaded,err=pcall(function()
            if not success or type(assets)~='table' or #assets==0 then error('Ассет недоступен / GetObjects не поддерживается') end
            name=assets[1].Name
            for _,asset in ipairs(assets) do
                local items=asset:GetDescendants(); table.insert(items,asset)
                for _,o in ipairs(items) do
                    if o:IsA('BasePart') then
                        partCount+=1
                        if partCount>400 then error('Слишком сложная модель: больше 400 деталей') end
                        local part=cleanPart(o)
                        if part then part.Parent=model end
                    end
                end
            end
            if #model:GetChildren()==0 then error('В этом ассете нет 3D-деталей') end
            -- Center the static geometry around the avatar root and normalize height.
            local cf,size=model:GetBoundingBox()
            if size.Y<.01 or size.Y>100000 then error('Неподходящие размеры модели') end
            for _,part in ipairs(model:GetChildren()) do part.CFrame=CFrame.new(-cf.Position)*part.CFrame end
            model.WorldPivot=CFrame.new()
            model:ScaleTo(model:GetScale()*5/size.Y)
        end)
        if success and type(assets)=='table' then for _,o in ipairs(assets) do o:Destroy() end end
        loadingModel=false; addModel.Text='Добавить'
        if not loaded then model:Destroy(); notify('Не удалось добавить: '..tostring(err)); return end
        local entry={id=id,name=name,model=model,baseScale=model:GetScale()}
        library[id]=entry
        entry.card=button(cards,'',UDim2.new(1,0,0,54)); entry.card.TextWrapped=true
        connect(entry.card.Activated,function() equip(entry); adjustScale() end)
        updateCards(); notify('Модель добавлена. Нажми карточку, чтобы надеть.')
    end)
end
connect(addModel.Activated,importModel)
connect(modelInput.FocusLost,function(enter) if enter then importModel() end end)
local customTimer=1
local function updateCustom(dt)
    local c=me.Character
    local h=c and c:FindFirstChildOfClass('Humanoid')
    if c and (not h or h.Health<=0) then
        restoreCharacter(); removeGhost(); removeSpin(); customTimer=1
        return
    end
    if hiddenCharacter and hiddenCharacter~=c then restoreCharacter(); removeGhost(); removeSpin(); customTimer=1 end
    if not customOn and not equipped and not spinOn and not danceRig and not catalogRig then
        if hiddenCharacter then restoreCharacter() end
        return
    end
    if not c then return end
    customTimer+=dt
    if customTimer>=.15 then
        customTimer=0; hiddenCharacter=c
        refreshSpin(c)
        refreshGhost(c)
        for _,o in ipairs(c:GetDescendants()) do
            if (o:IsA('BasePart') or o:IsA('Decal')) and not hiddenProperties[o] then
                local original=appearanceOriginals[o]
                hiddenProperties[o]={transparency=original and original.transparency or o.Transparency,
                    ltm=o:IsA('BasePart') and (original and original.ltm or o.LocalTransparencyModifier) or nil}
            end
        end
    end
    -- Run after the default camera transparency controller, which can reset LTM.
    for o,entry in pairs(hiddenProperties) do
        if o:IsDescendantOf(c) then
            if equipped or spinOn or danceRig or catalogRig then
                -- Never hide an equipped Tool until its visual mirror exists.
                local tool=(catalogRig or danceRig) and o:FindFirstAncestorOfClass('Tool')
                local sourcePart=o:IsA('BasePart') and o or o:FindFirstAncestorWhichIsA('BasePart')
                local mirror=sourcePart and (catalogRig and catalogToolMirrors[sourcePart] or (not catalogRig and danceToolMirrors[sourcePart]))
                local toolHasMirror=mirror and mirror.part and mirror.part.Parent
                if tool and not toolHasMirror then
                    o.Transparency=entry.transparency
                    if entry.ltm~=nil then o.LocalTransparencyModifier=0 end
                elseif entry.ltm~=nil then o.LocalTransparencyModifier=1
                else o.Transparency=1 end
            else
                -- Preserve intentionally invisible rig parts, e.g. the root.
                o.Transparency=math.max(entry.transparency,customTransparency)
                if entry.ltm~=nil then o.LocalTransparencyModifier=0 end
            end
        else
            pcall(function()
                o.Transparency=entry.transparency
                if entry.ltm~=nil then o.LocalTransparencyModifier=entry.ltm end
            end)
            hiddenProperties[o]=nil
        end
    end
    spinAngle=(spinAngle+math.rad(spinOn and spinSpeed or 0)*dt)%(math.pi*2)
    local r=charRoot(me)
    if spinModel and r then
        local transform=r.CFrame*CFrame.Angles(0,spinAngle,0)*r.CFrame:Inverse()
        for source,entry in pairs(spinParts) do
            if source:IsDescendantOf(c) then
                entry.part.CFrame=transform*source.CFrame; entry.part.Size=source.Size
                entry.part.Transparency=math.max(entry.transparency,customOn and customTransparency or 0)
                for decal,original in pairs(entry.decals) do
                    decal.Transparency=math.max(original,customOn and customTransparency or 0)
                end
            end
        end
    end
    if equipped then
        local r=charRoot(me)
        equipped.model:PivotTo((r and not danceRig and not catalogRig) and r.CFrame*CFrame.Angles(0,math.rad(modelYaw)+(spinOn and spinAngle or 0),0) or CFrame.new(0,-10000,0))
    end
end
respawnHooks.character=function()
    restoreCharacter(); removeGhost(); removeSpin(); customTimer=1
end
local customBinding='SakuraCustomAvatar_'..tostring(me.UserId)
RunService:BindToRenderStep(customBinding,Enum.RenderPriority.Camera.Value+2,updateCustom)
customCleanup=function()
    RunService:UnbindFromRenderStep(customBinding)
    restoreCharacter(); removeGhost(); removeSpin()
    for _,entry in pairs(library) do entry.model:Destroy() end
    library={}; equipped=nil
end

checkpoint('анти-флинг')
-- Client-side player/player exclusions, without changing collisions with
-- the map or rewriting any player's CanCollide/CollisionGroup properties.
;(function()
    local antiOn=false
    local exclusions=new('Folder',{Name='SakuraAntiFling'},root)
    local pairsByPart={}
    local elapsed=0
    local function resetPairs()
        exclusions:ClearAllChildren(); pairsByPart={}
    end
    toggle(settingsPage,'Анти-флинг • нет столкновений с игроками',false,function(on)
        antiOn=on; elapsed=1
        if not on then resetPairs() end
    end)
    note(settingsPage,'Анти-флинг: локальные NoCollisionConstraint между твоими деталями и деталями других игроков. Стены и пол остаются твёрдыми. Не защищает от скриптовых толчков, транспорта или серверной физики.')
    connect(RunService.Stepped,function(_,dt)
        if not antiOn then return end
        elapsed+=dt; if elapsed<.1 then return end; elapsed=0
        local character=me.Character
        if not character then resetPairs(); return end
        local mine,others={},{}
        for _,part in ipairs(character:GetDescendants()) do
            if part:IsA('BasePart') and part.CanCollide then mine[part]=true end
        end
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=me and p.Character then
                for _,part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA('BasePart') and part.CanCollide then others[part]=true end
                end
            end
        end
        for a,entries in pairs(pairsByPart) do
            for b,constraint in pairs(entries) do
                if not mine[a] or not others[b] then constraint:Destroy(); entries[b]=nil end
            end
            if not mine[a] then pairsByPart[a]=nil end
        end
        for a in pairs(mine) do
            pairsByPart[a]=pairsByPart[a] or {}
            for b in pairs(others) do
                if not pairsByPart[a][b] then
                    pairsByPart[a][b]=new('NoCollisionConstraint',{Part0=a,Part1=b,Enabled=true},exclusions)
                end
            end
        end
    end)
end)()

checkpoint('клон-гость')
-- Delayed guest: records world-space body poses, rather than applying
-- a fixed offset. Stopping lets the guest catch up and overlap the avatar.
;(function()
    local guestOn=false
    local guestDelay=.45
    local guestTransparency=.5
    local guestHighlightOn=false
    local guestSkinOn=false
    local guestHighlight=nil
    local setGuestSkinToggle
    local guestModel=nil
    local guestCharacter=nil
    local guestParts={}
    local guestBirth={}
    local guestRemoved={}
    local history={}
    local sampleTimer=0
    local rebuildTimer=0
    local lastRootPosition=nil
    local guestBinding='SakuraDelayedGuest_'..tostring(me.UserId)
    local function resetGuest()
        if guestModel then guestModel:Destroy() end
        guestModel=nil; guestVisualModel=nil; guestHighlight=nil; guestCharacter=nil; guestParts={}; history={}
        guestBirth={}; guestRemoved={}
        sampleTimer=0; rebuildTimer=0; lastRootPosition=nil
    end
    local function applySkin(part,source)
        if not guestSkinOn or source:FindFirstAncestorOfClass('Accessory')
            or source:FindFirstAncestorOfClass('Tool') or source:GetAttribute('SakuraVisualRole')=='Tool' then return end
        part.Color=colors.guestSkin
        part.Material=Enum.Material.SmoothPlastic
        part.MaterialVariant=''; part.Reflectance=0
        if part:IsA('PartOperation') then part.UsePartColor=true end
        if part:IsA('MeshPart') then pcall(function() part.TextureID='' end) end
        for _,o in ipairs(part:GetDescendants()) do
            if o:IsA('SurfaceAppearance') then o:Destroy()
            elseif o:IsA('SpecialMesh') then o.TextureId=''; o.VertexColor=Vector3.new(1,1,1) end
        end
    end
    local function applyBodyColors()
        if not guestModel then return end
        local body=guestModel:FindFirstChildOfClass('BodyColors')
        if body then body:Destroy() end
        local source=guestCharacter and guestCharacter:FindFirstChildOfClass('BodyColors')
        if guestSkinOn then
            body=new('BodyColors',{},guestModel)
            for _,key in ipairs({'HeadColor3','LeftArmColor3','RightArmColor3','LeftLegColor3','RightLegColor3','TorsoColor3'}) do
                body[key]=colors.guestSkin
            end
        elseif source then
            local copy=source:Clone(); if copy then copy.Parent=guestModel end
        end
    end
    local function applyGuestHighlight()
        if not guestModel then return end
        if guestHighlightOn then
            if not guestHighlight then
                guestHighlight=new('Highlight',{Name='GuestHighlight',Adornee=guestModel,
                    FillTransparency=.75,OutlineTransparency=0,
                    DepthMode=Enum.HighlightDepthMode.Occluded},guestModel)
            end
            guestHighlight.FillColor=colors.guestHighlight
            guestHighlight.OutlineColor=colors.guestHighlight
        elseif guestHighlight then guestHighlight:Destroy(); guestHighlight=nil end
    end
    local function makeGuestPart(source)
        local part=cleanPart(source)
        if not part then return nil end
        part.Transparency=guestTransparency
        part:SetAttribute('SakuraGuestVisible',false)
        part.LocalTransparencyModifier=0
        part.Anchored=true; part.CanCollide=false
        part.CanTouch=false; part.CanQuery=false; part.CastShadow=false
        for _,decal in ipairs(part:GetChildren()) do
            if decal:IsA('Decal') then
                local src=source:FindFirstChild(decal.Name)
                local data=src and hiddenProperties[src]
                decal.Transparency=data and data.transparency or decal.Transparency
            end
        end
        applySkin(part,source)
        return part
    end
    local function rebuildGuestAppearance()
        if not guestModel then return end
        -- Preserve delayed poses and the motion buffer when switching skins.
        for source,oldPart in pairs(guestParts) do
            if source:IsDescendantOf(guestCharacter) then
                local replacement=makeGuestPart(source)
                if replacement then
                    replacement.CFrame=oldPart.CFrame; replacement.Size=oldPart.Size
                    replacement.Parent=guestModel; guestParts[source]=replacement; oldPart:Destroy()
                end
            end
        end
        applyBodyColors()
    end
    local function syncParts(character)
        if not guestModel then
            guestModel=new('Model',{Name='SakuraGuest'},root)
            guestVisualModel=guestModel
            new('Humanoid',{DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None,
                RequiresNeck=false,BreakJointsOnDeath=false,AutoRotate=false},guestModel)
            for _,o in ipairs(character:GetChildren()) do
                if o:IsA('Shirt') or o:IsA('Pants') or o:IsA('ShirtGraphic') then
                    local ok,copy=pcall(function() return o:Clone() end)
                    if ok and copy then copy.Parent=guestModel end
                end
            end
            applyBodyColors(); applyGuestHighlight()
        end
        for source,part in pairs(guestParts) do
            if not source:IsDescendantOf(character) then
                guestRemoved[source]=guestRemoved[source] or os.clock()
                if os.clock()-guestDelay>=guestRemoved[source] then
                    part:Destroy(); guestParts[source]=nil; guestBirth[source]=nil; guestRemoved[source]=nil
                end
            else guestRemoved[source]=nil end
        end
        for _,source in ipairs(character:GetDescendants()) do
            if source:IsA('BasePart') and source.Name~='HumanoidRootPart'
                and not guestParts[source] then
                local saved=hiddenProperties[source]
                local original=source:GetAttribute('SakuraCatalogOriginalAlpha') or source:GetAttribute('SakuraDanceOriginalAlpha')
                    or source:GetAttribute('SakuraToolOriginalAlpha')
                    or (saved and saved.transparency) or source.Transparency
                if original<1 then
                    local part=makeGuestPart(source)
                    if part then
                        part.CFrame=source.CFrame; part.Parent=guestModel
                        guestParts[source]=part
                        guestBirth[source]=os.clock()
                        part.LocalTransparencyModifier=1
                    end
                end
            end
        end
    end
    toggle(characterPage,'Клон-гость',false,function(on)
        guestOn=on
        if not on then resetGuest() end
    end)
    numberSlider(characterPage,'Задержка клона (мс)',100,2000,450,'',function(v)
        guestDelay=v/1000
    end)
    numberSlider(characterPage,'Прозрачность клона',0,100,50,'%',function(v)
        guestTransparency=v/100
        for _,part in pairs(guestParts) do part.Transparency=guestTransparency end
    end)
    toggle(characterPage,'Клон-гость • Highlight',false,function(on)
        guestHighlightOn=on; applyGuestHighlight()
    end)
    setGuestSkinToggle=toggle(characterPage,'Клон-гость • свой цвет тела',false,function(on)
        guestSkinOn=on; rebuildGuestAppearance()
    end)
    connect(button(characterPage,'Цвет тела / Highlight клона → Цвета').Activated,function()
        selectPage(colorPage)
    end)
    guestColorChanged=function(key,c)
        if key=='guestHighlight' then
            applyGuestHighlight()
        elseif key=='guestSkin' then
            if not guestSkinOn then
                guestSkinOn=true; setGuestSkinToggle(true); rebuildGuestAppearance()
            else
                for source,part in pairs(guestParts) do applySkin(part,source) end
                applyBodyColors()
            end
        end
    end
    note(characterPage,'Клон повторяет видимый танец и Tool с задержкой. Цвета тела и Highlight — независимые, во вкладке «Цвета». Выбор цвета тела включает его перекраску; выключатель возвращает исходный вид.')
    note(characterPage,'Одежда и аксессуары сохраняют свой цвет. При перекраске тела убираются его меш-текстуры. На 100% прозрачности Roblox может не показывать Highlight.')
    local function updateGuest(dt)
        if not guestOn then return end
        local actual=me.Character
        local h=actual and actual:FindFirstChildOfClass('Humanoid')
        local character=catalogRig or danceRig or actual
        local r=charRoot(me)
        if not character or not r or not h or h.Health<=0 then
            if guestModel then resetGuest() end
            return
        end
        if guestCharacter~=character then resetGuest(); guestCharacter=character end
        if lastRootPosition and (r.Position-lastRootPosition).Magnitude>80 then
            -- Never interpolate a streak across the map after a teleport.
            resetGuest(); guestCharacter=character
        end
        lastRootPosition=r.Position
        rebuildTimer+=dt
        if not guestModel or rebuildTimer>=.2 then
            rebuildTimer=0; syncParts(character)
        end
        local now=os.clock()
        sampleTimer+=dt
        if #history==0 or sampleTimer>=1/30 then
            sampleTimer=0
            local frame={time=now,poses={}}
            for source in pairs(guestParts) do
                if source:IsDescendantOf(character) then
                    frame.poses[source]={cf=source.CFrame,size=source.Size}
                end
            end
            table.insert(history,frame)
        end
        -- Keep enough history for the maximum 2-second setting.
        while #history>2 and history[2].time<now-2.15 do table.remove(history,1) end
        if #history==0 then return end
        local when=now-guestDelay
        local before,after=history[1],history[1]
        for _,frame in ipairs(history) do
            if frame.time<=when then before=frame; after=frame
            else after=frame; break end
        end
        local duration=after.time-before.time
        local alpha=duration>0 and math.clamp((when-before.time)/duration,0,1) or 0
        for source,part in pairs(guestParts) do
            local a=before.poses[source]
            local b=after.poses[source]
            if (a or b) and when>=(guestBirth[source] or 0) then
                a=a or b; b=b or a
                part.CFrame=a.cf:Lerp(b.cf,alpha)
                part.Size=a.size:Lerp(b.size,alpha)
                part.LocalTransparencyModifier=0
                part:SetAttribute('SakuraGuestVisible',true)
            else
                part.LocalTransparencyModifier=1
                part:SetAttribute('SakuraGuestVisible',false)
            end
        end
    end
    RunService:BindToRenderStep(guestBinding,Enum.RenderPriority.Camera.Value+7,updateGuest)
    respawnHooks.guest=resetGuest
    local previousCleanup=customCleanup
    customCleanup=function()
        RunService:UnbindFromRenderStep(guestBinding)
        resetGuest(); guestColorChanged=nil
        if previousCleanup then previousCleanup() end
    end
end)()

checkpoint('танцы')
-- Avatar Shop emotes, not Creator Store models. Animations run only on a
-- locally created rig, so loading an emote cannot broadcast a real emote.
;(function()
    local Marketplace=game:GetService('MarketplaceService')
    local emotes={}
    local activeEntry=nil
    local activeTrack=nil
    local activeCharacter=nil
    local activePose=nil
    local generation=0
    local adding=false
    local speed=1
    local danceBinding='SakuraCatalogDance_'..tostring(me.UserId)
    local startDance
    note(dancePage,'Эмоции из магазина аватаров Roblox. Вставь ID или ссылку /catalog/… → «Добавить» → нажми карточку. Миниатюра — картинка из каталога, не видеопревью.')
    note(dancePage,'Танец виден только тебе и продолжается при ходьбе. Нужен R15 и доступ к анимации. Во время танца моделька-замена и визуальный спин временно скрыты.')
    local inputRow=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)},dancePage)
    local input=new('TextBox',{Text='124573621747512',PlaceholderText='ID эмоции / ссылка из магазина',ClearTextOnFocus=false,
        TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=12,BackgroundColor3=Color3.fromRGB(43,35,54),
        BorderSizePixel=0,Size=UDim2.new(.7,-6,1,0)},inputRow); round(input,8)
    local add=button(inputRow,'Добавить',UDim2.new(.3,0,1,0),UDim2.fromScale(.7,0))
    note(dancePage,'Экипированный Tool отображается в танцующей руке. Это визуальная копия предмета; настоящий Tool, его скрипты и управление остаются у персонажа.')
    local status=note(dancePage,'Танец не выбран.')
    local stop=button(dancePage,'Остановить танец / вернуть аватар')
    numberSlider(dancePage,'Скорость танца',25,200,100,'%',function(v)
        speed=v/100
        if activeTrack then activeTrack:AdjustSpeed(speed) end
    end)
    local cards=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},dancePage)
    new('UIListLayout',{Padding=UDim.new(0,8)},cards)
    local function drawCards()
        for _,entry in pairs(emotes) do
            entry.label.Text=(activeEntry==entry and '● ИГРАЕТ  •  ' or '▶ ВЫБРАТЬ  •  ')..entry.name
            entry.label.TextColor3=activeEntry==entry and pink or Color3.fromRGB(238,232,246)
        end
    end
    local function removeDanceRig()
        if activeTrack then pcall(function() activeTrack:Stop(0); activeTrack:Destroy() end) end
        activeTrack=nil
        if activePose and activePose.driver then activePose.driver:Destroy() end
        if danceRig then danceRig:Destroy() end
        danceRig=nil; activeCharacter=nil; activePose=nil; danceToolMirrors={}
        if not customOn and not equipped and not spinOn and not catalogRig then restoreCharacter() end
    end
    local function stopDance()
        generation+=1; removeDanceRig(); activeEntry=nil
        status.Text='Танец остановлен.'; drawCards()
    end
    connect(stop.Activated,stopDance)
    local function resolveAnimation(entry)
        if entry.animationId then return entry.animationId end
        local animationId=nil
        local ok,assets=pcall(function() return game:GetObjects('rbxassetid://'..entry.id) end)
        if ok and type(assets)=='table' then
            for _,asset in ipairs(assets) do
                local items=asset:GetDescendants(); table.insert(items,asset)
                for _,item in ipairs(items) do
                    if item:IsA('Animation') and item.AnimationId~='' then
                        animationId=item.AnimationId; break
                    end
                end
                if not animationId then
                    for _,item in ipairs(items) do
                        if item:IsA('KeyframeSequence') then
                            local registered,id=pcall(function()
                                return game:GetService('KeyframeSequenceProvider'):RegisterKeyframeSequence(item)
                            end)
                            if registered then animationId=id; break end
                        end
                    end
                end
            end
            -- None of the asset instances are ever parented into the game.
            for _,asset in ipairs(assets) do asset:Destroy() end
        end
        -- Some catalog emotes directly expose animation content at their asset ID.
        return animationId or 'rbxassetid://'..entry.id
    end
    local function cloneRig(character)
        local archival={}
        local originals=character:GetDescendants(); table.insert(originals,character)
        for _,o in ipairs(originals) do archival[o]=o.Archivable; o.Archivable=true end
        local ok,rig=pcall(function() return character:Clone() end)
        for o,value in pairs(archival) do pcall(function() o.Archivable=value end) end
        if not ok or not rig then error('Не удалось создать локальную копию аватара') end
        if not bodyComplete(rig) then rig:Destroy(); error('Аватар ещё не загрузился целиком. Повтори запуск танца.') end
        local pose={parts={},joints={},offsets={},root=nil,maxOffset=12}
        local ready,err=pcall(function()
            -- Restore original transparency on the clone, not on the real avatar.
            for source,data in pairs(hiddenProperties) do
                if source:IsDescendantOf(character) then
                    local path={}; local current=source
                    while current and current~=character do table.insert(path,1,current.Name); current=current.Parent end
                    local copy=rig
                    for _,name in ipairs(path) do copy=copy and copy:FindFirstChild(name) end
                    if copy then pcall(function() copy.Transparency=data.transparency end) end
                end
            end
            for _,o in ipairs(rig:GetDescendants()) do
                if o:IsA('LuaSourceContainer') or o:IsA('Tool') or o:IsA('Animator')
                    or o:IsA('Highlight') or o:IsA('BillboardGui') or o:IsA('Sound')
                    or o:IsA('RemoteEvent') or o:IsA('RemoteFunction')
                    or o:IsA('BodyMover') or o:IsA('Constraint') then
                    o:Destroy()
                elseif o:IsA('JointInstance') then
                    -- Clones can retain references to objects outside the cloned
                    -- character. Never allow a joint to touch the real avatar.
                    if not o.Part0 or not o.Part1 or not o.Part0:IsDescendantOf(rig)
                        or not o.Part1:IsDescendantOf(rig) then o:Destroy() end
                elseif o:IsA('ParticleEmitter') or o:IsA('Trail') or o:IsA('Beam') then
                    o.Enabled=false
                    if o:IsA('ParticleEmitter') or o:IsA('Trail') then pcall(function() o:Clear() end) end
                end
            end
            local r=rig:FindFirstChild('HumanoidRootPart')
            local h=rig:FindFirstChildOfClass('Humanoid')
            if not r or not h then error('В аватаре нет Humanoid / HumanoidRootPart') end
            rig.Name='SakuraLocalDance'; rig.PrimaryPart=r
            h.AutoRotate=false; h.RequiresNeck=false; h.BreakJointsOnDeath=false
            h.AutomaticScalingEnabled=false
            h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
            pcall(function() h.EvaluateStateMachine=false end)
            for _,o in ipairs(rig:GetDescendants()) do
                if o:IsA('BasePart') then
                    -- Fully kinematic: NO simulated body parts at any point.
                    o.Anchored=true; o.CanCollide=false; o.CanTouch=false
                    o.AssemblyLinearVelocity=Vector3.zero
                    o.AssemblyAngularVelocity=Vector3.zero
                    table.insert(pose.parts,o)
                    o:SetAttribute('SakuraPosePart',#pose.parts)
                    pose.offsets[o]=r.CFrame:ToObjectSpace(o.CFrame)
                    o.CanQuery=false; o.CastShadow=false; o.LocalTransparencyModifier=1
                    o:SetAttribute('SakuraDanceOriginalAlpha',o.Transparency)
                end
            end
            pose.root=r
            pose.maxOffset=math.max(12,math.min(40,rig:GetExtentsSize().Magnitude*1.5))
            for _,joint in ipairs(rig:GetDescendants()) do
                if joint:IsA('JointInstance') and joint.Part0 and joint.Part1
                    and joint.Part0:IsDescendantOf(rig) and joint.Part1:IsDescendantOf(rig) then
                    table.insert(pose.joints,{joint=joint,a=joint.Part0,b=joint.Part1,
                        motor=joint:IsA('Motor6D'),rootJoint=joint.Part0==r or joint.Part1==r})
                    joint:SetAttribute('SakuraPoseJoint',#pose.joints)
                end
            end
            r.Transparency=1; r:SetAttribute('SakuraDanceOriginalAlpha',1)
            -- Keep animation evaluation separate from the anchored display.
            -- Animation on a fully anchored assembly may never update its pose.
            local driver=rig:Clone(); pose.driver=driver
            driver.Name='SakuraDanceAnimationDriver'
            local dh=driver:FindFirstChildOfClass('Humanoid')
            if dh then dh:Destroy() end
            pose.driverRoot=driver:FindFirstChild('HumanoidRootPart')
            if not pose.driverRoot then error('Нет корня у анимационного скелета') end
            pose.driverParts={}
            pose.driverByPart={}
            pose.toolTimer=1
            local connected={[pose.driverRoot]=true}
            local driverJoints={}
            for _,o in ipairs(driver:GetDescendants()) do
                if o:IsA('JointInstance') then
                    local index=o:GetAttribute('SakuraPoseJoint')
                    if index and pose.joints[index] then
                        pose.joints[index].joint=o
                        table.insert(driverJoints,o)
                        if o:IsA('Motor6D') then o.Transform=CFrame.new() end
                    else o:Destroy() end
                elseif o:IsA('BasePart') then
                    o.Transparency=1; o.LocalTransparencyModifier=1
                    o.CanCollide=false; o.CanTouch=false; o.CanQuery=false
                    o.CastShadow=false; o.Massless=true
                    table.insert(pose.driverParts,o)
                    local index=o:GetAttribute('SakuraPosePart')
                    if index and pose.parts[index] then pose.driverByPart[pose.parts[index]]=o end
                elseif o:IsA('Decal') then o.Transparency=1
                elseif o:IsA('Animator') then o:Destroy() end
            end
            for _=1,#driverJoints+1 do
                local progress=false
                for _,joint in ipairs(driverJoints) do
                    if connected[joint.Part0] and not connected[joint.Part1] then
                        connected[joint.Part1]=true; progress=true
                    elseif connected[joint.Part1] and not connected[joint.Part0] then
                        connected[joint.Part0]=true; progress=true
                    end
                end
                if not progress then break end
            end
            for _,part in ipairs(pose.driverParts) do
                -- Only internally connected driver limbs are simulated. There
                -- is no Humanoid, collision, or joint connected to the player.
                part.Anchored=part==pose.driverRoot or not connected[part]
                part.AssemblyLinearVelocity=Vector3.zero
                part.AssemblyAngularVelocity=Vector3.zero
            end
            local controller=new('AnimationController',{},driver)
            pose.animator=new('Animator',{},controller)
            pcall(function() pose.animator.PreferLodEnabled=false end)
            driver.PrimaryPart=pose.driverRoot
            driver:PivotTo(character.HumanoidRootPart.CFrame)
            driver.Parent=root
            -- The visible copy never owns an Animator or moving physics parts.
            -- Motors are read from the separate driver, not from this copy.
            for _,o in ipairs(rig:GetDescendants()) do
                if o:IsA('JointInstance') then o:Destroy() end
            end
        end)
        if not ready then
            if pose.driver then pose.driver:Destroy() end
            rig:Destroy(); error(err)
        end
        return rig,pose
    end
    startDance=function(entry)
        generation+=1; local token=generation
        local character=me.Character
        local h=character and character:FindFirstChildOfClass('Humanoid')
        if not h or not charRoot(me) then notify('Дождись появления персонажа.'); return end
        if h.RigType~=Enum.HumanoidRigType.R15 then notify('Эмоции магазина рассчитаны на R15. Сейчас у тебя R6.'); return end
        status.Text='Загружаю: '..entry.name
        task.spawn(function()
            local rig,track,pose
            local ok,err=pcall(function()
                local deadline=os.clock()+12
                local stableSince=nil
                local lastCount=0
                while alive and token==generation and me.Character==character and os.clock()<deadline do
                    local count=#character:GetDescendants()
                    if bodyComplete(character) and count==lastCount then
                        stableSince=stableSince or os.clock()
                        if os.clock()-stableSince>=.6 then break end
                    else stableSince=nil end
                    lastCount=count
                    RunService.Heartbeat:Wait()
                end
                if not alive or token~=generation or me.Character~=character then return end
                if not bodyComplete(character) then error('После респавна ещё отсутствуют части тела. Нажми карточку позже.') end
                local animationId=resolveAnimation(entry)
                if not alive or token~=generation or me.Character~=character then return end
                rig,pose=cloneRig(character); rig.Parent=root
                local animation=new('Animation',{AnimationId=animationId})
                local animator=pose.animator
                local loaded,result=pcall(function() return animator:LoadAnimation(animation) end)
                animation:Destroy()
                if not loaded then error(result) end
                track=result; track.Priority=Enum.AnimationPriority.Action4; track.Looped=true
                track:Play(0,1,speed)
                local deadline=os.clock()+7
                while alive and token==generation and track.Length<=0 and os.clock()<deadline do RunService.Heartbeat:Wait() end
                if not alive or token~=generation or me.Character~=character then return end
                if track.Length<=0 then error('Анимация недоступна или не загрузилась. Попробуй другую эмоцию.') end
                -- Length > 0 only confirms download, not working animation.
                -- Check actual driver joint output before hiding the real avatar.
                local posed=false
                local poseDeadline=os.clock()+5
                while alive and token==generation and os.clock()<poseDeadline do
                    for _,entry in ipairs(pose.joints) do
                        if entry.motor and not entry.rootJoint and entry.joint.Transform~=CFrame.new() then
                            posed=true; break
                        end
                    end
                    if posed and track.TimePosition>.05 then break end
                    RunService.Heartbeat:Wait()
                end
                if not alive or token~=generation or me.Character~=character then return end
                if not posed or track.TimePosition<=.05 then
                    error('Клип загружен, но скелет не получил позу. Проверь доступ к эмоции или попробуй другую.')
                end
                entry.animationId=animationId
            end)
            if not alive or token~=generation or me.Character~=character or not ok or not rig or not track then
                if track then pcall(function() track:Stop(0); track:Destroy() end) end
                if pose and pose.driver then pose.driver:Destroy() end
                if rig then rig:Destroy() end
                if alive and token==generation then
                    status.Text='Ошибка: '..tostring(err or 'Анимация не найдена'); notify(status.Text)
                end
                return
            end
            removeDanceRig(); removeSpin()
            danceRig=rig; activeTrack=track; activeCharacter=character; activeEntry=entry; activePose=pose
            customTimer=1
            refreshGhost(character)
            status.Text='Играет: '..entry.name..' • ходьба не останавливает танец'
            drawCards()
        end)
    end
    catalogPlayEmote=function(id,name) startDance({id=tostring(id),name=name or ('Эмоция '..tostring(id))}) end
    catalogDanceSource=function() return activeTrack end
    local function addEmote()
        if adding then notify('Подожди загрузки карточки.'); return end
        local raw=input.Text:match('^%s*(.-)%s*$')
        local id=raw:match('^(%d+)$') or raw:match('/catalog/(%d+)')
        if not id or #id>16 or tonumber(id)<=0 then notify('Введи ID или ссылку roblox.com/catalog/… на эмоцию.'); return end
        if emotes[id] then notify('Эта эмоция уже есть в карточках.'); return end
        local count=0; for _ in pairs(emotes) do count+=1 end
        if count>=16 then notify('Лимит: 16 карточек эмоций за запуск.'); return end
        adding=true; add.Text='Загрузка…'
        task.spawn(function()
            local ok,info=pcall(function() return Marketplace:GetProductInfo(tonumber(id),Enum.InfoType.Asset) end)
            if not alive then return end
            adding=false; add.Text='Добавить'
            if not ok or not info then notify('Не удалось получить данные эмоции из магазина.'); return end
            if info.AssetTypeId~=Enum.AssetType.EmoteAnimation.Value then
                notify('Это не эмоция магазина аватаров. Нужен Emote Animation, не модель или одежда.'); return
            end
            local entry={id=id,name=info.Name or ('Эмоция '..id)}
            local card=button(cards,'',UDim2.new(1,0,0,86))
            local image=new('ImageLabel',{BackgroundColor3=Color3.fromRGB(33,27,43),BorderSizePixel=0,
                Position=UDim2.fromOffset(8,8),Size=UDim2.fromOffset(70,70),ScaleType=Enum.ScaleType.Fit,
                Image='rbxthumb://type=Asset&id='..id..'&w=150&h=150'},card); round(image,8)
            entry.label=text(card,'',13,UDim2.fromOffset(89,10),UDim2.new(1,-100,0,44)); entry.label.TextWrapped=true
            local details=text(card,'ID '..id..'  •  магазин аватаров',10,UDim2.fromOffset(89,58),UDim2.new(1,-100,0,18)); details.TextColor3=muted
            emotes[id]=entry
            connect(card.Activated,function() if activeEntry==entry then stopDance() else startDance(entry) end end)
            drawCards(); notify('Эмоция добавлена. Нажми карточку для запуска.')
        end)
    end
    connect(add.Activated,addEmote)
    connect(input.FocusLost,function(enter) if enter then addEmote() end end)
    respawnHooks.dance=function() generation+=1; removeDanceRig() end
    connect(me.CharacterAdded,function(character)
        local entry=activeEntry
        if not entry then return end
        task.spawn(function()
            local r=character:WaitForChild('HumanoidRootPart',10)
            local h=character:WaitForChild('Humanoid',10)
            if alive and r and h and me.Character==character and activeEntry==entry then startDance(entry) end
        end)
    end)
    -- Animator writes transforms after PreAnimation and before PreSimulation.
    -- Keep the hidden driver nearby without ever writing the real root's CFrame.
    connect(RunService.PreSimulation,function()
        if not activePose or not activePose.driver or not activePose.driverRoot then return end
        local r=charRoot(me)
        if not r or me.Character~=activeCharacter then return end
        activePose.driverRoot.CFrame=r.CFrame
        for _,part in ipairs(activePose.driverParts) do
            if part.Parent then
                part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
            end
        end
    end)
    local function toolHand(character,tool)
        -- Match the actual grip, including left-handed and nonstandard tools.
        for _,joint in ipairs(character:GetDescendants()) do
            if joint:IsA('JointInstance') and joint.Part0 and joint.Part1 then
                local aIn=joint.Part0:IsDescendantOf(tool)
                local bIn=joint.Part1:IsDescendantOf(tool)
                if aIn~=bIn then
                    local hand=aIn and joint.Part1 or joint.Part0
                    if hand:IsDescendantOf(character) and not hand:FindFirstAncestorOfClass('Tool') then return hand end
                end
            end
        end
        return character:FindFirstChild('RightHand') or character:FindFirstChild('Right Arm')
    end
    local function syncDanceTools(character)
        for source,entry in pairs(danceToolMirrors) do
            if not source:IsDescendantOf(character) or not entry.tool:IsDescendantOf(character)
                or not entry.hand:IsDescendantOf(character) then
                entry.part:Destroy(); danceToolMirrors[source]=nil
            end
        end
        for _,tool in ipairs(character:GetChildren()) do
            if tool:IsA('Tool') then
                local hand=toolHand(character,tool)
                local visualHand=hand and danceRig:FindFirstChild(hand.Name)
                if hand and visualHand and visualHand:IsA('BasePart') then
                    for _,source in ipairs(tool:GetDescendants()) do
                        if source:IsA('BasePart') then
                            local entry=danceToolMirrors[source]
                            if not entry then
                                -- Geometry only: never clone or execute weapon scripts.
                                local part=cleanPart(source)
                                if part then
                                    local original=hiddenProperties[source]
                                    local alpha=original and original.transparency or source.Transparency
                                    part.Transparency=alpha; part.LocalTransparencyModifier=0
                                    part.Name='DanceTool_'..source.Name
                                    part:SetAttribute('SakuraVisualRole','Tool')
                                    part:SetAttribute('SakuraToolOriginalAlpha',alpha)
                                    for _,decal in ipairs(part:GetChildren()) do
                                        if decal:IsA('Decal') then
                                            local src=source:FindFirstChild(decal.Name)
                                            local data=src and hiddenProperties[src]
                                            if data then decal.Transparency=data.transparency end
                                        end
                                    end
                                    part.CFrame=visualHand.CFrame*hand.CFrame:ToObjectSpace(source.CFrame)
                                    part.Parent=danceRig
                                    entry={part=part,alpha=alpha,tool=tool,hand=hand,visualHand=visualHand}
                                    danceToolMirrors[source]=entry
                                end
                            else
                                entry.hand=hand; entry.visualHand=visualHand
                            end
                        end
                    end
                end
            end
        end
    end
    -- Use Roblox's already-evaluated poses, including native neck rotations,
    -- accessory welds, and the small hip translations used by dance steps.
    -- No manual C0/C1 solver and no forced removal of root-joint translation.
    local function renderDancePose(dt)
        if not danceRig or not activePose then return end
        local r=charRoot(me)
        if not r or me.Character~=activeCharacter then return end
        local pose=activePose
        local rootFrame=r.CFrame
        local driverRoot=pose.driverRoot
        if not driverRoot or not driverRoot:IsDescendantOf(pose.driver) then
            error('Анимационный скелет потерял корень')
        end
        local driverFrame=driverRoot.CFrame
        local targets={}
        local valid=true
        for _,part in ipairs(pose.parts) do
            local driverPart=pose.driverByPart[part]
            if part:IsDescendantOf(danceRig) then
                local localPose=driverPart and driverPart:IsDescendantOf(pose.driver)
                    and driverFrame:ToObjectSpace(driverPart.CFrame) or pose.offsets[part]
                if part==pose.root then localPose=CFrame.new() end
                local distance=localPose.Position.Magnitude
                -- Reject an entire broken frame instead of snapping individual
                -- limbs to their rest pose and producing a twisted character.
                if distance~=distance or distance>pose.maxOffset then valid=false; break end
                targets[part]=localPose
            end
        end
        if valid then pose.lastGoodTargets=targets else targets=pose.lastGoodTargets or pose.offsets end
        for part,localPose in pairs(targets) do
            if part:IsDescendantOf(danceRig) then
                part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
                part.CFrame=rootFrame*localPose
                part.LocalTransparencyModifier=catalogRig and 1 or 0
                part.Transparency=math.max(part:GetAttribute('SakuraDanceOriginalAlpha') or 0,customOn and customTransparency or 0)
            end
        end
        pose.toolTimer+=dt or 0
        if pose.toolTimer>=.1 then pose.toolTimer=0; syncDanceTools(activeCharacter) end
        for source,entry in pairs(danceToolMirrors) do
            if source:IsDescendantOf(activeCharacter) and entry.hand.Parent and entry.visualHand.Parent then
                entry.part.CFrame=entry.visualHand.CFrame*entry.hand.CFrame:ToObjectSpace(source.CFrame)
                entry.part.Size=source.Size
                entry.part.Color=source.Color
                entry.part.Transparency=entry.alpha
                entry.part.LocalTransparencyModifier=catalogRig and 1 or 0
                entry.part.Anchored=true; entry.part.CanCollide=false
                entry.part.CanTouch=false; entry.part.CanQuery=false
            end
        end
    end
    RunService:BindToRenderStep(danceBinding,Enum.RenderPriority.Camera.Value+4,function(dt)
        local ok,err=pcall(renderDancePose,dt)
        if not ok then
            stopDance()
            notify('Танец остановлен из-за ошибки позы: '..tostring(err))
        end
    end)
    local previousCleanup=customCleanup
    customCleanup=function()
        generation+=1
        RunService:UnbindFromRenderStep(danceBinding)
        removeDanceRig()
        if previousCleanup then previousCleanup() end
    end
end)()

checkpoint('внешность (хедлесс/корблокс)')
-- Local appearance only. No body parts are deleted, resized, or detached
-- on the actual character; toggles and respawns restore visibility safely.
;(function()
    local headless=false
    local korblox=false
    local loading=false
    local template=nil
    local templateHip=CFrame.new()
    local proxies={}
    local appearanceBinding='SakuraAppearance_'..tostring(me.UserId)
    local setKorblox
    local function restorePart(part,data)
        pcall(function()
            -- Custom-avatar rendering may already have set this frame's LTM.
            if not hiddenProperties[part] then part.LocalTransparencyModifier=data.ltm end
        end)
    end
    local function resetAppearance()
        for part,data in pairs(appearanceOriginals) do restorePart(part,data) end
        appearanceOriginals={}
        for _,proxy in pairs(proxies) do proxy:Destroy() end
        proxies={}
    end
    local function loadKorblox()
        if loading or template then return end
        loading=true
        task.spawn(function()
            local ok,assets=pcall(function() return game:GetObjects('rbxassetid://139607718') end)
            local chosen=nil
            if ok and type(assets)=='table' then
                for _,asset in ipairs(assets) do
                    local items=asset:GetDescendants(); table.insert(items,asset)
                    for _,item in ipairs(items) do
                        if item:IsA('BasePart') and item.Name=='RightUpperLeg' then chosen=item; break end
                    end
                    if chosen then break end
                end
            end
            local copy=nil
            if chosen and alive then
                local hip=chosen:FindFirstChild('RightHipRigAttachment')
                templateHip=hip and hip.CFrame or CFrame.new(0,chosen.Size.Y/2,0)
                copy=cleanPart(chosen)
            end
            if ok and type(assets)=='table' then for _,asset in ipairs(assets) do asset:Destroy() end end
            loading=false
            if not alive then if copy then copy:Destroy() end; return end
            if copy then
                template=copy; template.Name='KorbloxRightLegTemplate'
                notify('Korblox загружен. Это локальная замена, без изменения аккаунта.')
            else
                korblox=false; if setKorblox then setKorblox(false) end
                notify('Korblox: правую ногу 139607718 загрузить не удалось. Настоящая нога не скрыта.')
            end
        end)
    end
    note(characterPage,'Локальная внешность: Headless и Korblox. Настоящие части тела не удаляются. Сохраняется после респавна, видна только тебе.')
    toggle(characterPage,'Хедлесс • скрыть голову и лицо',false,function(on) headless=on end)
    setKorblox=toggle(characterPage,'Корблокс • правая нога (R15)',false,function(on)
        local h=me.Character and me.Character:FindFirstChildOfClass('Humanoid')
        if on and h and h.RigType~=Enum.HumanoidRigType.R15 then
            setKorblox(false); notify('Korblox в этой версии требует R15.'); return
        end
        korblox=on; if on then loadKorblox() end
    end)
    note(characterPage,'Korblox использует правую ногу Roblox 139607718. Если ассет недоступен, эффект не включится. Headless не удаляет волосы и головные аксессуары.')
    local function renderAppearance()
        local wanted={}
        local used={}
        local models={}
        local real=me.Character
        if real then table.insert(models,{model=real,show=not catalogRig and not danceRig and not spinModel and not equipped}) end
        if catalogRig then table.insert(models,{model=catalogRig,show=true}) end
        if danceRig then table.insert(models,{model=danceRig,show=not catalogRig}) end
        if spinModel then table.insert(models,{model=spinModel,show=not catalogRig and not danceRig and not equipped}) end
        if guestVisualModel then table.insert(models,{model=guestVisualModel,show=true}) end
        local function hide(part)
            if not part or not part:IsA('BasePart') then return end
            wanted[part]=true
            if not appearanceOriginals[part] then
                local original=hiddenProperties[part]
                appearanceOriginals[part]={transparency=original and original.transparency or part.Transparency,
                    ltm=original and original.ltm or part.LocalTransparencyModifier}
            end
            part.LocalTransparencyModifier=1
        end
        local h=real and real:FindFirstChildOfClass('Humanoid')
        local function bodyScale(name)
            local value=h and h:FindFirstChild(name)
            return value and value:IsA('NumberValue') and math.clamp(value.Value,.1,5) or 1
        end
        local scaleVector=Vector3.new(bodyScale('BodyWidthScale'),bodyScale('BodyHeightScale'),bodyScale('BodyDepthScale'))
        for _,entry in ipairs(models) do
            local model=entry.model
            if headless then hide(model:FindFirstChild('Head')) end
            if korblox and template then
                local upper=model:FindFirstChild('RightUpperLeg')
                if upper and upper:IsA('BasePart') then
                    hide(upper); hide(model:FindFirstChild('RightLowerLeg')); hide(model:FindFirstChild('RightFoot'))
                    if entry.show and upper:GetAttribute('SakuraGuestVisible')~=false then
                        local proxy=proxies[upper]
                        if not proxy then
                            proxy=template:Clone(); proxy.Name='SakuraKorbloxVisual'
                            proxy:SetAttribute('SakuraAppearanceProxy',true)
                            proxy.Parent=root; proxies[upper]=proxy
                        end
                        used[upper]=true
                        proxy.Size=template.Size*scaleVector
                        local hip=upper:FindFirstChild('RightHipRigAttachment')
                        local sourceHip=hip and hip.CFrame or CFrame.new(0,upper.Size.Y/2,0)
                        local scaledHip=CFrame.new(templateHip.Position*scaleVector)*templateHip.Rotation
                        proxy.CFrame=upper.CFrame*sourceHip*scaledHip:Inverse()
                        proxy.Transparency=upper.Transparency
                        proxy.LocalTransparencyModifier=0
                        proxy.Anchored=true; proxy.CanCollide=false; proxy.CanTouch=false; proxy.CanQuery=false
                    end
                end
            end
        end
        for part,data in pairs(appearanceOriginals) do
            if not wanted[part] then restorePart(part,data); appearanceOriginals[part]=nil end
        end
        for source,proxy in pairs(proxies) do
            if not used[source] then proxy:Destroy(); proxies[source]=nil end
        end
    end
    RunService:BindToRenderStep(appearanceBinding,Enum.RenderPriority.Camera.Value+8,renderAppearance)
    respawnHooks.appearance=resetAppearance
    local previousCleanup=customCleanup
    customCleanup=function()
        RunService:UnbindFromRenderStep(appearanceBinding)
        if previousCleanup then previousCleanup() end
        resetAppearance()
        if template then template:Destroy(); template=nil end
    end
end)()

checkpoint('юзер-читы HUD')
-- Other clients' injected code is NOT observable from a LocalScript.
-- This HUD only flags sustained replicated movement, with explicit caveats.
-- It never fetches or runs any cheat loader, reports players, or bans anyone.
;(function()
    local enabled=false
    local threshold=90
    local samples={}
    local suspects={}
    local timer=0
    local hud=new('Frame',{Name='MovementObservationHUD',Position=UDim2.new(1,-330,0,64),
        Size=UDim2.fromOffset(310,247),BackgroundColor3=Color3.fromRGB(25,20,33),BackgroundTransparency=.08,
        BorderSizePixel=0,Visible=false},gui); round(hud,12)
    new('UIStroke',{Color=pink,Transparency=.5},hud)
    local handle=button(hud,'ЮЗЕР-ЧИТЕР • НАБЛЮДЕНИЕ',UDim2.new(1,-16,0,35),UDim2.fromOffset(8,8))
    handle.TextSize=12
    local disclaimer=text(hud,'Подозрения ≠ доказательства. Чужой код не виден.',10,UDim2.fromOffset(12,47),UDim2.new(1,-24,0,30))
    disclaimer.TextWrapped=true; disclaimer.TextColor3=muted
    local list=text(hud,'Наблюдение выключено.',12,UDim2.fromOffset(12,83),UDim2.new(1,-24,1,-112))
    list.TextWrapped=true; list.TextYAlignment=Enum.TextYAlignment.Top
    local footer=text(hud,'Перетаскивание — только при открытом меню',9,UDim2.new(0,12,1,-23),UDim2.new(1,-24,0,16)); footer.TextColor3=muted
    note(detectionPage,'Нельзя определить ThunderXHUB или загрузчик Luarmor на чужом клиенте. Их код не реплицируется. Этот HUD показывает только признаки необычного движения, а не факт читерства.')
    toggle(detectionPage,'HUD • подозрительные перемещения',false,function(on)
        enabled=on; hud.Visible=on; samples={}; suspects={}; timer=1
        list.Text=on and 'Собираю наблюдения…' or 'Наблюдение выключено.'
    end)
    numberSlider(detectionPage,'Порог скорости (studs/сек)',40,250,90,'',function(v) threshold=v; samples={}; suspects={} end)
    connect(button(detectionPage,'Очистить список / начать заново').Activated,function()
        samples={}; suspects={}; list.Text='Наблюдения очищены.'
    end)
    note(detectionPage,'Условие: скорость по горизонтали выше порога не менее 3 секунд. Респавн, сидение и большие скачки позиции пропускаются. Способности игры и лаг всё равно могут дать ложную отметку.')
    note(detectionPage,'HUD можно двигать мышью или пальцем за заголовок, пока открыто меню. Имена появляются только у игроков, для которых клиент получил данные персонажа.')
    local drag=nil
    local dragStart=nil
    local startPosition=nil
    local function hudOffset()
        local camera=workspace.CurrentCamera
        local viewport=camera and camera.ViewportSize or Vector2.new(800,600)
        local inset=game:GetService('GuiService'):GetGuiInset()
        return Vector2.new(hud.Position.X.Scale*viewport.X+hud.Position.X.Offset,
            hud.Position.Y.Scale*(viewport.Y-inset.Y)+hud.Position.Y.Offset)
    end
    local function clampHUD(x,y)
        local camera=workspace.CurrentCamera
        local viewport=camera and camera.ViewportSize or Vector2.new(800,600)
        local inset=game:GetService('GuiService'):GetGuiInset()
        local width=math.min(310,math.max(180,viewport.X-16))
        local height=math.min(247,math.max(150,viewport.Y-inset.Y-16))
        hud.Size=UDim2.fromOffset(width,height)
        hud.Position=UDim2.fromOffset(math.clamp(x,8,math.max(8,viewport.X-width-8)),
            math.clamp(y,8,math.max(8,viewport.Y-inset.Y-height-8)))
    end
    connect(handle.InputBegan,function(input)
        if not window.Visible then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            drag=input; dragStart=input.Position; startPosition=hudOffset()
        end
    end)
    connect(UIS.InputChanged,function(input)
        if not drag then return end
        if not window.Visible then drag=nil; return end
        if input==drag or (drag.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement) then
            local delta=input.Position-dragStart
            clampHUD(startPosition.X+delta.X,startPosition.Y+delta.Y)
        end
    end)
    connect(UIS.InputEnded,function(input)
        if drag and (input==drag or (drag.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)) then drag=nil end
    end)
    connect(UIS.WindowFocusReleased,function() drag=nil end)
    connect(Players.PlayerRemoving,function(p) samples[p]=nil; suspects[p]=nil end)
    connect(RunService.Heartbeat,function(dt)
        if not enabled then return end
        timer+=dt; if timer<.25 then return end; timer=0
        local now=os.clock()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=me then
                local c=p.Character
                local r=c and c:FindFirstChild('HumanoidRootPart')
                local h=c and c:FindFirstChildOfClass('Humanoid')
                if not r or not h or h.Health<=0 then samples[p]=nil; suspects[p]=nil
                else
                    local prev=samples[p]
                    if not prev or prev.character~=c then
                        samples[p]={character=c,position=r.Position,time=now,grace=now+5,sustained=0}
                        suspects[p]=nil
                    else
                        local elapsed=now-prev.time
                        local displacement=r.Position-prev.position
                        local speed=Vector3.new(displacement.X,0,displacement.Z).Magnitude/math.max(elapsed,.001)
                        local cutoff=math.max(threshold,h.WalkSpeed*1.8)
                        if elapsed>1.25 or displacement.Magnitude>150 or speed>500 or h.Sit or h.SeatPart then
                            prev.sustained=0; prev.grace=now+3
                        elseif now<prev.grace then prev.sustained=0
                        elseif speed>cutoff then
                            prev.sustained+=elapsed
                            if prev.sustained>=3 then
                                suspects[p]={untilTime=now+15,speed=math.floor(speed),cutoff=math.floor(cutoff)}
                            end
                        else prev.sustained=0 end
                        prev.time=now; prev.position=r.Position
                    end
                end
            end
        end
        local entries={}
        for p,info in pairs(suspects) do
            if p.Parent~=Players or now>info.untilTime then suspects[p]=nil
            else table.insert(entries,{player=p,info=info}) end
        end
        table.sort(entries,function(a,b) return a.info.speed>b.info.speed end)
        local lines={}
        for i,entry in ipairs(entries) do
            if i>3 then table.insert(lines,'… ещё '..tostring(#entries-3)); break end
            table.insert(lines,string.format('@%s — подозрение\nСкорость %d > %d, держалась ≥3 с',entry.player.Name,entry.info.speed,entry.info.cutoff))
        end
        list.Text=#lines>0 and table.concat(lines,'\n\n') or 'Подозрительных перемещений не отмечено.\n\nЭто не означает, что чужие скрипты отсутствуют.'
        local offset=hudOffset(); clampHUD(offset.X,offset.Y)
    end)
end)()

checkpoint('каталог')
-- Avatar Shop browsing and LOCAL try-on. Never prompts a purchase or saves
-- the outfit to Roblox. User text is a search query/ID, never executable code.
;(function()
    local editor=game:GetService('AvatarEditorService')
    local market=game:GetService('MarketplaceService')
    local assets=game:GetService('AssetService')
    local description=nil
    local driver=nil
    local displayParts={}
    local driverParts={}
    local mirrors={}
    local poseOffsets={}
    local poseJoints={}
    local proceduralPose=nil
    local poseAnchor=nil
    local anchorJoint=nil
    local anchorForward=true
    local anchorRestOffset=CFrame.new()
    local accessoryBindings={parts={},roots={},children={}}
    local currentCharacter=nil
    local generation=0
    local morphOn=false
    local morphSession=false
    local morphApplied=false
    local morphVersion=0
    local morphBackup=nil
    local stopMorph,loadMorph,setMorphToggle
    local morphUsername='' 
    local searchGeneration=0
    local itemGeneration=0
    local pagesObject=nil
    local category='Все'
    local categories={'Все','Эмоции','Аксессуары','Одежда','Бандлы'}
    local animationCache={}
    local failedAnimations={}
    local loadStarted={}
    local motion={kind='idle',rate=1,phase=0,jumpUntil=0,track=nil,emote=false,lastChange=0,observed={}}
    local motionStatus=nil
    local syncTimer=0
    local hipHeight=2
    local rebuilder
    local binding='SakuraCatalogAvatar_'..tostring(me.UserId)
    local assetNames={}
    for _,v in ipairs(Enum.AssetType:GetEnumItems()) do assetNames[v.Value]=v.Name end
    local accessoryTypes={Hat='Hat',HairAccessory='Hair',FaceAccessory='Face',NeckAccessory='Neck',
        ShoulderAccessory='Shoulder',FrontAccessory='Front',BackAccessory='Back',WaistAccessory='Waist',
        TShirtAccessory='TShirt',ShirtAccessory='Shirt',PantsAccessory='Pants',JacketAccessory='Jacket',
        SweaterAccessory='Sweater',ShortsAccessory='Shorts',LeftShoeAccessory='LeftShoe',RightShoeAccessory='RightShoe',
        DressSkirtAccessory='DressSkirt',EyebrowAccessory='Eyebrow',EyelashAccessory='Eyelash'}
    local rigid={Hat=true,Hair=true,Face=true,Neck=true,Shoulder=true,Front=true,Back=true,Waist=true}
    local fields={TShirt='GraphicTShirt',Shirt='Shirt',Pants='Pants',Face='Face',Head='Head',DynamicHead='Head',
        Torso='Torso',LeftArm='LeftArm',RightArm='RightArm',LeftLeg='LeftLeg',RightLeg='RightLeg'}
    note(catalogPage,'Магазин аватаров Roblox: поиск, карточки и локальная примерка. Предметы не покупаются и не сохраняются на аккаунт. Для примерки нужен R15.')
    local filters=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,75)},catalogPage)
    new('UIGridLayout',{CellSize=UDim2.new(1/3,-5,0,32),CellPadding=UDim2.fromOffset(6,6)},filters)
    local filterButtons={}
    local searchRow=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)},catalogPage)
    local query=new('TextBox',{Text='',PlaceholderText='Название, ID или ссылка Roblox',ClearTextOnFocus=false,
        TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=12,BackgroundColor3=Color3.fromRGB(43,35,54),
        BorderSizePixel=0,Size=UDim2.new(.73,-6,1,0)},searchRow); round(query,8)
    local searchButton=button(searchRow,'Найти',UDim2.new(.27,0,1,0),UDim2.fromScale(.73,0))
    local status=note(catalogPage,'Введи запрос или выбери категорию.')
    local resetButton=button(catalogPage,'Снять примерку / вернуть свой аватар')
    local nextPage=button(catalogPage,'Следующая страница'); nextPage.Visible=false
    local results=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},catalogPage)
    new('UIGridLayout',{CellSize=UDim2.new(.5,-5,0,182),CellPadding=UDim2.fromOffset(8,8),SortOrder=Enum.SortOrder.LayoutOrder},results)
    local searchCatalog
    local function clearRig()
        for _,track in pairs(animationCache) do pcall(function() track:Stop(0); track:Destroy() end) end
        animationCache={}; failedAnimations={}; catalogToolMirrors={}; loadStarted={}
        poseJoints={}; proceduralPose=nil
        motion={kind='idle',rate=1,phase=0,jumpUntil=0,track=nil,emote=false,lastChange=0,observed={}}
        if motionStatus then motionStatus.Text='Анимации: ожидание морфа.' end
        if catalogRig then catalogRig:Destroy() end
        if driver then driver:Destroy() end
        catalogRig=nil; driver=nil; displayParts={}; driverParts={}; mirrors={}; currentCharacter=nil
        accessoryBindings={parts={},roots={},children={}}
        poseOffsets={}; poseAnchor=nil; anchorJoint=nil; anchorRestOffset=CFrame.new()
        if not customOn and not danceRig and not equipped and not spinOn then restoreCharacter() end
    end
    local function seedCatalogPose()
        poseOffsets={}; anchorJoint=nil; poseJoints={}
        local rootPart=driver and driver:FindFirstChild('HumanoidRootPart')
        if not rootPart then return end
        poseAnchor=driver:FindFirstChild('LowerTorso') or rootPart
        anchorRestOffset=rootPart.CFrame:ToObjectSpace(poseAnchor.CFrame)
        for _,joint in ipairs(driver:GetDescendants()) do
            if joint:IsA('Motor6D') then
                if joint.Part0==rootPart and joint.Part1==poseAnchor then
                    anchorJoint=joint; anchorForward=true; break
                elseif joint.Part1==rootPart and joint.Part0==poseAnchor then
                    anchorJoint=joint; anchorForward=false; break
                end
            end
        end
        for _,joint in ipairs(driver:GetDescendants()) do
            if joint:IsA('Motor6D') and joint.Part0 and joint.Part1
                and joint.Part0.Parent==driver and joint.Part1.Parent==driver then
                table.insert(poseJoints,{joint=joint,a=joint.Part0,b=joint.Part1,name=joint.Name})
            end
        end
        for _,part in ipairs(displayParts) do
            local source=mirrors[part]
            if source then poseOffsets[part]=rootPart.CFrame:ToObjectSpace(source.CFrame) end
        end
    end
    local function solveCatalogJoints(rootPart,entries,overrides)
        local solved={[rootPart]=CFrame.new()}
        for _=1,#entries+1 do
            local progress=false
            for _,entry in ipairs(entries) do
                local joint=entry.joint
                if joint.Parent and entry.a.Parent and entry.b.Parent then
                    local transform=overrides and (overrides[entry.name] or CFrame.new()) or joint.Transform
                    if solved[entry.a] and not solved[entry.b] then
                        solved[entry.b]=solved[entry.a]*joint.C0*transform*joint.C1:Inverse(); progress=true
                    elseif solved[entry.b] and not solved[entry.a] then
                        solved[entry.a]=solved[entry.b]*joint.C1*transform:Inverse()*joint.C0:Inverse(); progress=true
                    end
                end
            end
            if not progress then break end
        end
        return solved
    end
    local function sampleCatalogPose()
        if not catalogRig or not driver or not poseAnchor or not poseAnchor.Parent then return end
        local rootPart=driver:FindFirstChild('HumanoidRootPart')
        if not rootPart then return end
        -- Evaluate the torso anchor in ROOT-LOCAL space. Reading a freshly
        -- moved root against stale limb world positions would cancel the
        -- player's movement and pin the visible morph at its spawn location.
        local torsoOffset=anchorRestOffset
        if anchorJoint and anchorJoint.Parent then
            if anchorForward then
                torsoOffset=anchorJoint.C0*anchorJoint.Transform*anchorJoint.C1:Inverse()
            else
                torsoOffset=anchorJoint.C1*anchorJoint.Transform:Inverse()*anchorJoint.C0:Inverse()
            end
        end
        local anchorFrame=poseAnchor.CFrame
        local solved=solveCatalogJoints(rootPart,poseJoints,proceduralPose)
        for _,part in ipairs(displayParts) do
            local source=mirrors[part]
            if source and source.Parent and part.Parent and not accessoryBindings.parts[part] then
                local relative=solved[source] or (source==rootPart and CFrame.new()
                    or torsoOffset*anchorFrame:ToObjectSpace(source.CFrame))
                local distance=relative.Position.Magnitude
                if distance==distance and distance<60 then poseOffsets[part]=relative end
            end
        end
    end
    connect(resetButton.Activated,function()
        if morphSession and stopMorph then stopMorph(false) end
        generation+=1; itemGeneration+=1; clearRig()
        if description then description:Destroy(); description=nil end
        status.Text='Примерка снята.'
    end)
    local function baseDescription()
        if description then return description:Clone() end
        local h=me.Character and me.Character:FindFirstChildOfClass('Humanoid')
        if not h then error('Дождись появления персонажа.') end
        return h:GetAppliedDescription()
    end
    -- Rigid avatar accessories are constrained by attachment frames, not by
    -- where their loose Handles happen to be when a generated model is cloned.
    local function buildAccessoryBindings(model)
        local bindings={parts={},roots={},children={}}
        local bodyAttachments={}
        for _,body in ipairs(model:GetChildren()) do
            if body:IsA('BasePart') then
                for _,attachment in ipairs(body:GetChildren()) do
                    if attachment:IsA('Attachment') then
                        bodyAttachments[attachment.Name]=bodyAttachments[attachment.Name] or {}
                        table.insert(bodyAttachments[attachment.Name],{part=body,attachment=attachment})
                    end
                end
            end
        end
        local fallbackBody={Hat='Head',Hair='Head',Face='Head',Eyebrow='Head',Eyelash='Head',
            Neck='UpperTorso',Shoulder='UpperTorso',Front='UpperTorso',Back='UpperTorso',
            Waist='LowerTorso',LeftShoe='LeftFoot',RightShoe='RightFoot',Pants='LowerTorso',
            Shorts='LowerTorso',DressSkirt='LowerTorso',Shirt='UpperTorso',TShirt='UpperTorso',
            Jacket='UpperTorso',Sweater='UpperTorso'}
        for _,accessory in ipairs(model:GetChildren()) do
            if accessory:IsA('Accoutrement') then
                local handle=accessory:FindFirstChild('Handle')
                if handle and handle:IsA('BasePart') then
                    local binding=nil
                    -- Prefer Roblox's named attachment pair; this works before
                    -- the physics solver has ever positioned the Handle.
                    for _,attachment in ipairs(handle:GetChildren()) do
                        if attachment:IsA('Attachment') then
                            local matches=bodyAttachments[attachment.Name]
                            if matches and matches[1] then
                                local match=matches[1]
                                binding={part=handle,body=match.part,bodyAttachment=match.attachment,
                                    handleAttachment=attachment}
                                break
                            end
                        end
                    end
                    -- Legacy accessories may provide only an AccessoryWeld.
                    -- Read its offsets before display joints are removed.
                    if not binding then
                        for _,joint in ipairs(accessory:GetDescendants()) do
                            if joint:IsA('JointInstance') and joint.Part0 and joint.Part1 then
                                if joint.Part0==handle and joint.Part1:IsDescendantOf(model)
                                    and not joint.Part1:IsDescendantOf(accessory) then
                                    binding={part=handle,body=joint.Part1,bodyOffset=joint.C1,handleOffset=joint.C0}
                                    break
                                elseif joint.Part1==handle and joint.Part0:IsDescendantOf(model)
                                    and not joint.Part0:IsDescendantOf(accessory) then
                                    binding={part=handle,body=joint.Part0,bodyOffset=joint.C0,handleOffset=joint.C1}
                                    break
                                end
                            end
                        end
                    end
                    if not binding then
                        local kind='Hat'
                        if accessory:IsA('Accessory') then kind=accessory.AccessoryType.Name end
                        local body=model:FindFirstChild(fallbackBody[kind] or 'Head')
                        if body and body:IsA('BasePart') then
                            local offset=body.Name=='Head' and CFrame.new(0,body.Size.Y/2,0) or CFrame.new()
                            binding={part=handle,body=body,bodyOffset=offset,handleOffset=accessory.AttachmentPoint}
                        end
                    end
                    if binding then
                        table.insert(bindings.roots,binding); bindings.parts[handle]=true
                        for _,part in ipairs(accessory:GetDescendants()) do
                            if part:IsA('BasePart') and part~=handle then
                                bindings.parts[part]=true
                                table.insert(bindings.children,{part=part,handle=handle,offset=handle.CFrame:ToObjectSpace(part.CFrame)})
                            end
                        end
                    end
                end
            end
        end
        return bindings
    end
    local function renderAccessories(bindings)
        -- Body parts have already received the current animation pose.
        -- Matching attachments must have equal world-space frames:
        -- body.CFrame * bodyAttachment = handle.CFrame * handleAttachment.
        for _,entry in ipairs(bindings.roots) do
            if entry.part.Parent and entry.body.Parent then
                local bodyOffset=entry.bodyAttachment and entry.bodyAttachment.CFrame or entry.bodyOffset
                local handleOffset=entry.handleAttachment and entry.handleAttachment.CFrame or entry.handleOffset
                entry.part.CFrame=entry.body.CFrame*bodyOffset*handleOffset:Inverse()
            end
        end
        for _,entry in ipairs(bindings.children) do
            if entry.part.Parent and entry.handle.Parent then entry.part.CFrame=entry.handle.CFrame*entry.offset end
        end
    end
    local function ensureR15Motors(model)
        local links={
            {'HumanoidRootPart','LowerTorso','Root','RootRigAttachment'},
            {'LowerTorso','UpperTorso','Waist','WaistRigAttachment'},
            {'UpperTorso','Head','Neck','NeckRigAttachment'},
            {'UpperTorso','LeftUpperArm','LeftShoulder','LeftShoulderRigAttachment'},
            {'LeftUpperArm','LeftLowerArm','LeftElbow','LeftElbowRigAttachment'},
            {'LeftLowerArm','LeftHand','LeftWrist','LeftWristRigAttachment'},
            {'UpperTorso','RightUpperArm','RightShoulder','RightShoulderRigAttachment'},
            {'RightUpperArm','RightLowerArm','RightElbow','RightElbowRigAttachment'},
            {'RightLowerArm','RightHand','RightWrist','RightWristRigAttachment'},
            {'LowerTorso','LeftUpperLeg','LeftHip','LeftHipRigAttachment'},
            {'LeftUpperLeg','LeftLowerLeg','LeftKnee','LeftKneeRigAttachment'},
            {'LeftLowerLeg','LeftFoot','LeftAnkle','LeftAnkleRigAttachment'},
            {'LowerTorso','RightUpperLeg','RightHip','RightHipRigAttachment'},
            {'RightUpperLeg','RightLowerLeg','RightKnee','RightKneeRigAttachment'},
            {'RightLowerLeg','RightFoot','RightAnkle','RightAnkleRigAttachment'}
        }
        for _,link in ipairs(links) do
            local a=model:FindFirstChild(link[1]); local b=model:FindFirstChild(link[2])
            if a and b then
                local found=false
                for _,joint in ipairs(model:GetDescendants()) do
                    if joint:IsA('Motor6D') and ((joint.Part0==a and joint.Part1==b) or (joint.Part0==b and joint.Part1==a)) then
                        pcall(function() joint.Enabled=true end); found=true; break
                    end
                end
                if not found then
                    local aa=a:FindFirstChild(link[4]); local ab=b:FindFirstChild(link[4])
                    if aa and ab then new('Motor6D',{Name=link[3],Part0=a,Part1=b,C0=aa.CFrame,C1=ab.CFrame},b) end
                end
            end
        end
    end
    local function prepareRig(model)
        local h=model:FindFirstChildOfClass('Humanoid')
        local r=model:FindFirstChild('HumanoidRootPart')
        if not h or not r or not bodyComplete(model) then error('Модель каталога не содержит полного аватара.') end
        model.PrimaryPart=r; model.Name='SakuraCatalogAvatar'; model.Archivable=true
        h.AutomaticScalingEnabled=false; h.AutoRotate=false; h.RequiresNeck=false; h.BreakJointsOnDeath=false
        h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
        pcall(function() h.EvaluateStateMachine=false end)
        local parts={}
        for _,o in ipairs(model:GetDescendants()) do
            o.Archivable=true
            if o:IsA('LuaSourceContainer') or o:IsA('Animator') or o:IsA('Tool') or o:IsA('BodyMover')
                or o:IsA('Constraint') or o:IsA('Sound') then o:Destroy()
            elseif o:IsA('JointInstance') then
                if not o.Part0 or not o.Part1 or not o.Part0:IsDescendantOf(model) or not o.Part1:IsDescendantOf(model) then o:Destroy() end
            elseif o:IsA('BasePart') then
                table.insert(parts,o); o:SetAttribute('SakuraCatalogPart',#parts)
                o:SetAttribute('SakuraCatalogOriginalAlpha',o==r and 1 or o.Transparency)
                o.Anchored=true; o.CanCollide=false; o.CanTouch=false; o.CanQuery=false; o.CastShadow=false
                o.LocalTransparencyModifier=1
            end
        end
        local bindings=buildAccessoryBindings(model)
        renderAccessories(bindings)
        local native=model:Clone(); native.Name='SakuraCatalogDriver'
        native:FindFirstChildOfClass('Humanoid'):Destroy()
        ensureR15Motors(native)
        local nativeParts,map={},{ }
        local rootPart=native:FindFirstChild('HumanoidRootPart')
        for _,o in ipairs(native:GetDescendants()) do
            if o:IsA('BasePart') then
                table.insert(nativeParts,o)
                local i=o:GetAttribute('SakuraCatalogPart'); if i then map[parts[i]]=o end
                o.Transparency=1; o.LocalTransparencyModifier=1
                o.Massless=true; o.Anchored=o==rootPart
                o.CanCollide=false; o.CanTouch=false; o.CanQuery=false
            elseif o:IsA('Decal') then o.Transparency=1 end
        end
        local connected={[rootPart]=true}
        local joints={}
        for _,o in ipairs(native:GetDescendants()) do if o:IsA('JointInstance') then table.insert(joints,o) end end
        for _=1,#joints+1 do
            local changed=false
            for _,joint in ipairs(joints) do
                if connected[joint.Part0] and not connected[joint.Part1] then connected[joint.Part1]=true; changed=true
                elseif connected[joint.Part1] and not connected[joint.Part0] then connected[joint.Part0]=true; changed=true end
            end
            if not changed then break end
        end
        for _,part in ipairs(nativeParts) do part.Anchored=part==rootPart or not connected[part] end
        local controller=new('AnimationController',{},native)
        local animator=new('Animator',{},controller)
        pcall(function() animator.PreferLodEnabled=false end)
        for _,o in ipairs(model:GetDescendants()) do if o:IsA('JointInstance') then o:Destroy() end end
        return native,parts,nativeParts,map,h.HipHeight,bindings
    end
    rebuilder=function(newDescription,title,onComplete)
        generation+=1; local token=generation
        local character=me.Character
        local h=character and character:FindFirstChildOfClass('Humanoid')
        if not h or h.RigType~=Enum.HumanoidRigType.R15 then
            newDescription:Destroy(); notify('Для примерки каталога нужен R15.')
            if onComplete then onComplete(false,'Для примерки каталога нужен R15.') end
            return
        end
        status.Text='Примеряю: '..title
        task.spawn(function()
            local model,native,parts,nativeParts,map,height,bindings
            local ok,err=pcall(function()
                local success,result=pcall(function() return Players:CreateHumanoidModelFromDescriptionAsync(newDescription,Enum.HumanoidRigType.R15) end)
                if not success then result=Players:CreateHumanoidModelFromDescription(newDescription,Enum.HumanoidRigType.R15) end
                model=result
                if not model then error('Roblox не вернул модель аватара.') end
                native,parts,nativeParts,map,height,bindings=prepareRig(model)
            end)
            if not alive or token~=generation or me.Character~=character or not ok then
                if model then model:Destroy() end; if native then native:Destroy() end; newDescription:Destroy()
                if alive and token==generation then
                    status.Text='Примерка не удалась: '..tostring(err or 'Персонаж изменился'); notify(status.Text)
                    if onComplete then onComplete(false,tostring(err or 'Персонаж изменился')) end
                end
                return
            end
            clearRig(); removeSpin()
            if description then description:Destroy() end
            description=newDescription; catalogRig=model; driver=native
            displayParts=parts; driverParts=nativeParts; mirrors=map; hipHeight=height; currentCharacter=character
            accessoryBindings=bindings
            model:PivotTo(character.HumanoidRootPart.CFrame); native:PivotTo(character.HumanoidRootPart.CFrame)
            seedCatalogPose()
            native.Parent=root; model.Parent=root; syncTimer=1; customTimer=1
            refreshGhost(character)
            status.Text='Примерено: '..title..' • только на твоём экране'
            if onComplete then onComplete(true) end
        end)
    end
    -- Morph uses the same isolated avatar renderer as catalog try-on.
    -- The backup is captured once per toggle session, not on each name edit.
    note(morphPage,'Введи username Roblox, а не Display Name. Игрок не обязан быть на сервере. Морф меняет только твою локальную внешность; имя и аккаунт остаются твоими.')
    local usernameInput=new('TextBox',{Text='Simoon68',PlaceholderText='Ник игрока / @username',ClearTextOnFocus=false,
        Size=UDim2.new(1,0,0,40),BackgroundColor3=Color3.fromRGB(43,35,54),BorderSizePixel=0,
        TextColor3=Color3.new(1,1,1),Font=Enum.Font.Gotham,TextSize=14},morphPage); round(usernameInput,9)
    cfgExtra('Morph Player • ник',function() return usernameInput.Text end,function(value)
        if type(value)=='string' and value~='' then usernameInput.Text=value end
    end)
    local morphStatus=note(morphPage,'Морф выключен.')
    local preview=new('Frame',{BackgroundColor3=Color3.fromRGB(30,24,39),BorderSizePixel=0,Size=UDim2.new(1,0,0,82)},morphPage); round(preview,10)
    local previewImage=new('ImageLabel',{BackgroundTransparency=1,Size=UDim2.fromOffset(66,66),Position=UDim2.fromOffset(8,8),Image=''},preview); round(previewImage,8)
    local previewName=text(preview,'Игрок не выбран',13,UDim2.fromOffset(86,14),UDim2.new(1,-98,0,26)); previewName.TextTruncate=Enum.TextTruncate.AtEnd
    local previewId=text(preview,'',11,UDim2.fromOffset(86,44),UDim2.new(1,-98,0,20)); previewId.TextColor3=muted
    local function normalizedUsername(raw)
        local name=raw:match('^%s*(.-)%s*$'):gsub('^@','')
        if #name<1 or #name>20 or not name:match('^[A-Za-z0-9_]+$') then return nil end
        return name
    end
    stopMorph=function(restorePrevious)
        morphVersion+=1; generation+=1; itemGeneration+=1
        morphOn=false; morphSession=false; morphUsername=''
        if setMorphToggle then setMorphToggle(false) end
        local previous=morphBackup; morphBackup=nil
        local wasApplied=morphApplied; morphApplied=false
        -- A cancelled/failed lookup never needs to destroy the existing look.
        if restorePrevious and not wasApplied then
            if previous then previous:Destroy() end
            morphStatus.Text='Морф выключен.'
            return
        end
        clearRig()
        if description then description:Destroy(); description=nil end
        morphStatus.Text='Морф выключен.'
        if previous and restorePrevious then
            -- Preserve the backup as committed state even if respawn interrupts
            -- its rebuild. CharacterAdded can safely reapply it later.
            description=previous:Clone()
            local h=me.Character and me.Character:FindFirstChildOfClass('Humanoid')
            if h and h.Health>0 and bodyComplete(me.Character) then
                morphStatus.Text='Морф выключен. Восстанавливаю предыдущий образ…'
                local version=morphVersion
                rebuilder(previous,'Предыдущий образ',function(ok)
                    if not alive or version~=morphVersion then return end
                    morphStatus.Text=ok and 'Предыдущий образ восстановлен.' or 'Не удалось восстановить примерку. Показан твой обычный аватар.'
                end)
            else previous:Destroy() end
        elseif previous then previous:Destroy() end
    end
    loadMorph=function()
        local name=normalizedUsername(usernameInput.Text)
        if not name then
            if morphSession then stopMorph(true) else morphOn=false; setMorphToggle(false) end
            notify('Ник должен содержать 1–20 латинских букв, цифр или подчёркиваний.'); return
        end
        local character=me.Character
        local h=character and character:FindFirstChildOfClass('Humanoid')
        if h and h.RigType~=Enum.HumanoidRigType.R15 then
            if morphSession then stopMorph(true) else morphOn=false; setMorphToggle(false) end
            notify('Для Morph Player нужен R15.'); return
        end
        if not morphSession then
            morphSession=true; morphApplied=false
            morphBackup=description and description:Clone() or nil
        end
        morphOn=true; morphUsername=name
        morphVersion+=1; generation+=1; itemGeneration+=1
        local version=morphVersion
        morphStatus.Text='Ищу игрока: @'..name
        previewImage.Image=''
        previewName:SetAttribute('SakuraNoTranslate',true); previewName.Text='@'..name; previewId.Text=''
        task.spawn(function()
            local wanted=nil
            local ok,err=pcall(function()
                local found,id=pcall(function() return Players:GetUserIdFromNameAsync(name) end)
                if not found or type(id)~='number' or id<=0 then error('Пользователь не найден или Roblox не ответил. Проверь username.') end
                if not alive or not morphOn or version~=morphVersion then return end
                morphStatus.Text='Загружаю аватар: @'..name
                previewImage.Image='rbxthumb://type=AvatarHeadShot&id='..id..'&w=150&h=150'
                previewId.Text='User ID: '..id
                local loaded,result=pcall(function() return Players:GetHumanoidDescriptionFromUserIdAsync(id) end)
                if not loaded then loaded,result=pcall(function() return Players:GetHumanoidDescriptionFromUserId(id) end) end
                if not loaded or not result then error('Не удалось загрузить аватар игрока.') end
                wanted=result
            end)
            if not alive or not morphOn or version~=morphVersion then
                if wanted then wanted:Destroy() end
                return
            end
            if not ok or not wanted then
                stopMorph(true)
                morphStatus.Text='Ошибка морфа: '..tostring(err or 'Не удалось загрузить аватар игрока.')
                notify(morphStatus.Text); return
            end
            -- Keep the real avatar visible until the full replacement is ready.
            local deadline=os.clock()+12
            while alive and morphOn and version==morphVersion and me.Character==character
                and not bodyComplete(character) and os.clock()<deadline do RunService.Heartbeat:Wait() end
            if not alive or not morphOn or version~=morphVersion or me.Character~=character then wanted:Destroy(); return end
            rebuilder(wanted,'@'..name,function(success,reason)
                if not alive or not morphOn or version~=morphVersion then return end
                if success then morphApplied=true; morphStatus.Text='Морф активен: @'..name
                else
                    stopMorph(true)
                    morphStatus.Text='Ошибка морфа: '..tostring(reason or 'Не удалось загрузить аватар игрока.')
                end
            end)
        end)
    end
    setMorphToggle=toggle(morphPage,'Morph Player • включить морф',false,function(on)
        if on then morphOn=true; loadMorph() else stopMorph(true) end
    end)
    connect(usernameInput.FocusLost,function(enter)
        if morphOn and (enter or normalizedUsername(usernameInput.Text)~=morphUsername) then loadMorph() end
    end)
    note(morphPage,'Выключатель возвращает предыдущую примерку или твой аватар. Измени ник и нажми Enter, чтобы сменить морф. Работает с R15 и восстанавливается после респавна.')

    local function applyAsset(desc,id,info)
        local kind=assetNames[info.AssetTypeId]
        if kind=='EmoteAnimation' then return 'emote' end
        local accessory=accessoryTypes[kind]
        if accessory then
            local list=desc:GetAccessories(true)
            local found=false
            for i=#list,1,-1 do if list[i].AssetId==id then table.remove(list,i); found=true end end
            if not found then
                table.insert(list,{AssetId=id,AccessoryType=Enum.AccessoryType[accessory],IsLayered=not rigid[accessory],Order=#list+1})
            end
            desc:SetAccessories(list,true); return 'outfit'
        end
        local field=fields[kind]
        if field then desc[field]=id; return 'outfit' end
        error('Этот тип предмета пока нельзя примерить: '..tostring(kind or info.AssetTypeId))
    end
    local function equipItem(item)
        itemGeneration+=1; local ticket=itemGeneration
        local character=me.Character
        status.Text='Загружаю предмет: '..item.name
        task.spawn(function()
            local desc=nil
            local ok,err=pcall(function()
                if item.kind=='Bundle' then
                    if morphOn then error('Выключи Morph Player перед примеркой одежды или бандлов в каталоге. Эмоции можно использовать.') end
                    local bundle=assets:GetBundleDetailsAsync(item.id)
                    if tostring(bundle.BundleType):find("Animations") then error('В этом бандле нет поддерживаемых частей тела.') end
                    desc=baseDescription()
                    local outfitId=nil
                    for _,entry in ipairs(bundle.Items or {}) do if entry.Type=='UserOutfit' then outfitId=entry.Id; break end end
                    if outfitId then
                        local success,body=pcall(function() return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId) end)
                        if not success then body=Players:GetHumanoidDescriptionFromOutfitId(outfitId) end
                        for _,field in ipairs({'Head','Torso','LeftArm','RightArm','LeftLeg','RightLeg'}) do if body[field]>0 then desc[field]=body[field] end end
                        if body.Torso>0 or body.LeftLeg>0 or body.RightLeg>0 then
                            for _,field in ipairs({'HeightScale','WidthScale','DepthScale','HeadScale','BodyTypeScale','ProportionScale'}) do desc[field]=body[field] end
                        end
                        local combined=desc:GetAccessories(true)
                        local known={}; for _,accessory in ipairs(combined) do known[accessory.AssetId]=true end
                        for _,accessory in ipairs(body:GetAccessories(true)) do
                            if not known[accessory.AssetId] then
                                accessory.Order=#combined+1; table.insert(combined,accessory); known[accessory.AssetId]=true
                            end
                        end
                        desc:SetAccessories(combined,true)
                        body:Destroy()
                    else
                        local applied=false
                        for _,entry in ipairs(bundle.Items or {}) do
                            if entry.Type=='Asset' then
                                local info=market:GetProductInfo(entry.Id,Enum.InfoType.Asset)
                                local field=fields[assetNames[info.AssetTypeId]]
                                if field then desc[field]=entry.Id; applied=true
                                elseif accessoryTypes[assetNames[info.AssetTypeId]] then applyAsset(desc,entry.Id,info); applied=true end
                            end
                        end
                        if not applied then error('В этом бандле нет поддерживаемых частей тела.') end
                    end
                else
                    local info=market:GetProductInfo(item.id,Enum.InfoType.Asset)
                    if assetNames[info.AssetTypeId]=='EmoteAnimation' then
                        if not alive or ticket~=itemGeneration or me.Character~=character then return end
                        catalogPlayEmote(item.id,info.Name)
                        status.Text='Эмоция отправлена в «Танцы»: '..info.Name
                        return
                    end
                    if morphOn then error('Выключи Morph Player перед примеркой одежды или бандлов в каталоге. Эмоции можно использовать.') end
                    desc=baseDescription(); applyAsset(desc,item.id,info)
                end
                if not alive or ticket~=itemGeneration or me.Character~=character then if desc then desc:Destroy(); desc=nil end; return end
                local ready=desc; desc=nil; rebuilder(ready,item.name)
            end)
            if not ok then
                if desc then desc:Destroy() end
                if alive and ticket==itemGeneration then status.Text='Ошибка: '..tostring(err); notify(status.Text) end
            end
        end)
    end
    local function showItems(items)
        for _,o in ipairs(results:GetChildren()) do if o:IsA('GuiObject') then o:Destroy() end end
        local count=0
        for _,raw in ipairs(items) do
            local id=tonumber(raw.Id or raw.id)
            if id then
                count+=1; if count>30 then break end
                local item={id=id,name=raw.Name or raw.name or tostring(id),kind=(raw.ItemType=='Bundle' or raw.itemType=='Bundle' or raw.BundleType) and 'Bundle' or 'Asset'}
                local card=button(results,'',UDim2.new(.5,-5,0,182))
                new('ImageLabel',{BackgroundTransparency=1,Position=UDim2.new(.5,-42,0,5),Size=UDim2.fromOffset(84,84),ScaleType=Enum.ScaleType.Fit,
                    Image='rbxthumb://type='..(item.kind=='Bundle' and 'BundleThumbnail' or 'Asset')..'&id='..id..'&w=150&h=150'},card)
                local name=text(card,item.name,11,UDim2.fromOffset(8,93),UDim2.new(1,-16,0,38)); name.TextWrapped=true; name.TextXAlignment=Enum.TextXAlignment.Center; name:SetAttribute('SakuraNoTranslate',true)
                local price=raw.Price or raw.price
                local caption=text(card,(item.kind=='Bundle' and 'Бандл' or 'Предмет')..' • '..(price and tostring(price)..' R$' or '—'),10,UDim2.fromOffset(6,133),UDim2.new(1,-12,0,18)); caption.TextXAlignment=Enum.TextXAlignment.Center; caption.TextColor3=muted
                local action=text(card,'ПРИМЕРИТЬ',11,UDim2.fromOffset(6,156),UDim2.new(1,-12,0,18)); action.TextXAlignment=Enum.TextXAlignment.Center; action.TextColor3=pink
                connect(card.Activated,function() equipItem(item) end)
            end
        end
        status.Text=count>0 and ('Найдено на странице: '..math.min(count,30)) or 'Ничего не найдено. Измени запрос.'
    end
    searchCatalog=function()
        searchGeneration+=1; local token=searchGeneration
        local keyword=query.Text:match('^%s*(.-)%s*$')
        status.Text='Поиск в каталоге…'; nextPage.Visible=false
        task.spawn(function()
            local pageList,newPages
            local ok,err=pcall(function()
                local bundleId=keyword:match('/bundles/(%d+)')
                local assetId=keyword:match('/catalog/(%d+)') or keyword:match('^(%d+)$')
                if bundleId or (assetId and category=='Бандлы') then
                    local id=tonumber(bundleId or assetId); local info=assets:GetBundleDetailsAsync(id)
                    pageList={{Id=id,Name=info.Name,ItemType='Bundle'}}
                elseif assetId then
                    local id=tonumber(assetId); local info=market:GetProductInfo(id,Enum.InfoType.Asset)
                    pageList={{Id=id,Name=info.Name,ItemType='Asset',Price=info.PriceInRobux}}
                else
                    local params=CatalogSearchParams.new(); params.SearchKeyword=keyword; params.IncludeOffSale=false
                    local types={}
                    local function addType(name) local success,value=pcall(function() return Enum.AvatarAssetType[name] end); if success then table.insert(types,value) end end
                    if category=='Эмоции' then addType('EmoteAnimation')
                    elseif category=='Аксессуары' then for name in pairs(accessoryTypes) do if rigid[accessoryTypes[name]] then addType(name) end end
                    elseif category=='Одежда' then
                        for _,name in ipairs({'TShirt','Shirt','Pants'}) do addType(name) end
                        for name,accessory in pairs(accessoryTypes) do if not rigid[accessory] then addType(name) end end
                    elseif category=='Бандлы' then
                        params.BundleTypes={Enum.BundleType.BodyParts,Enum.BundleType.DynamicHead,Enum.BundleType.DynamicHeadAvatar,Enum.BundleType.Shoes}
                    end
                    if #types>0 then params.AssetTypes=types end
                    local success,result=pcall(function() return editor:SearchCatalogAsync(params) end)
                    if not success then result=editor:SearchCatalog(params) end
                    newPages=result; pageList=newPages:GetCurrentPage()
                end
            end)
            if not alive or token~=searchGeneration then return end
            if not ok then status.Text='Каталог недоступен: '..tostring(err); notify('Поиск не удался. Можно попробовать точный ID или ссылку предмета.'); return end
            pagesObject=newPages; showItems(pageList or {})
            nextPage.Visible=newPages~=nil and not newPages.IsFinished
        end)
    end
    for _,name in ipairs(categories) do
        local b=button(filters,name); filterButtons[name]=b
        if name==category then b.TextColor3=pink end
        connect(b.Activated,function()
            category=name
            for key,btn in pairs(filterButtons) do btn.TextColor3=key==category and pink or Color3.fromRGB(239,231,247) end
            searchCatalog()
        end)
    end
    connect(searchButton.Activated,searchCatalog)
    connect(query.FocusLost,function(enter) if enter then searchCatalog() end end)
    local paging=false
    connect(nextPage.Activated,function()
        if not pagesObject or paging then return end
        paging=true; local selected=pagesObject; local token=searchGeneration
        task.spawn(function()
            local ok,err=pcall(function() selected:AdvanceToNextPageAsync() end)
            paging=false
            if not alive or token~=searchGeneration then return end
            if ok then showItems(selected:GetCurrentPage()); nextPage.Visible=not selected.IsFinished
            else status.Text='Следующая страница недоступна: '..tostring(err) end
        end)
    end)
    note(morphPage,'Анимации морфа включаются автоматически: ожидание, ходьба, бег и прыжок. Это движения морфа, а не обязательно анимационный пак владельца профиля.')
    motionStatus=note(morphPage,'Анимации: ожидание морфа.')
    local motionNames={idle='ожидание',walk='ходьба',run='бег',jump='прыжок',fall='падение',climb='лазание',swim='плавание',swimidle='плавание',sit='сидение'}
    local motionIds={idle='507766388',walk='507777826',run='507767714',jump='507765000',fall='507767968',
        climb='507765644',swim='507784897',swimidle='507785072',sit='2506281703'}
    local function selectMorphMotion(h,r,now,previousJump)
        local state=h:GetState()
        local velocity=r.AssemblyLinearVelocity
        local horizontal=Vector3.new(velocity.X,0,velocity.Z).Magnitude
        local moving=h.MoveDirection.Magnitude>.05
        if h.Sit or state==Enum.HumanoidStateType.Seated then return 'sit',1,0 end
        if state==Enum.HumanoidStateType.Climbing then return 'climb',math.clamp(math.abs(velocity.Y)/5,.5,2),0 end
        if state==Enum.HumanoidStateType.Swimming then return moving and 'swim' or 'swimidle',1,0 end
        if state==Enum.HumanoidStateType.Jumping then return 'jump',1,now+.3 end
        if state==Enum.HumanoidStateType.Freefall then return now<previousJump and 'jump' or 'fall',1,previousJump end
        if moving then
            local speed=horizontal>.5 and horizontal or h.WalkSpeed
            if speed>20 then return 'run',math.clamp(speed/20,.55,2),0 end
            return 'walk',math.clamp(speed/14,.55,2),0
        end
        return 'idle',1,0
    end
    local function proceduralMorphPose(kind,phase,now,holdingTool)
        local pose={}
        local function turn(name,x,y,z) pose[name]=CFrame.Angles(x or 0,y or 0,z or 0) end
        local swing=math.sin(phase)
        if kind=='walk' or kind=='run' then
            local amplitude=kind=='run' and .9 or .6
            turn('LeftHip',swing*amplitude); turn('RightHip',-swing*amplitude)
            turn('LeftKnee',math.max(0,-swing)*.75); turn('RightKnee',math.max(0,swing)*.75)
            turn('LeftShoulder',-swing*amplitude*.8); turn('RightShoulder',swing*amplitude*.8)
            turn('LeftElbow',kind=='run' and -.5 or -.12); turn('RightElbow',kind=='run' and -.5 or -.12)
            turn('Waist',kind=='run' and -.10 or 0,math.sin(phase)*.045,0)
            pose.Root=CFrame.new(0,math.abs(math.cos(phase))*.04,0)
        elseif kind=='jump' then
            turn('LeftShoulder',-.8,0,-.1); turn('RightShoulder',-.8,0,.1)
            turn('LeftHip',-.25); turn('RightHip',-.25); turn('LeftKnee',.6); turn('RightKnee',.6)
        elseif kind=='fall' then
            turn('LeftShoulder',-.15,0,-.35); turn('RightShoulder',-.15,0,.35)
            turn('LeftKnee',.2); turn('RightKnee',.2)
        elseif kind=='sit' then
            turn('LeftHip',-1.45); turn('RightHip',-1.45); turn('LeftKnee',1.4); turn('RightKnee',1.4)
        elseif kind=='climb' then
            turn('LeftShoulder',-1.5+swing*.5); turn('RightShoulder',-1.5-swing*.5)
            turn('LeftHip',swing*.4); turn('RightHip',-swing*.4)
            turn('LeftKnee',.45); turn('RightKnee',.45)
        elseif kind=='swim' then
            turn('Waist',-.5); turn('LeftShoulder',swing*.9); turn('RightShoulder',-swing*.9)
            turn('LeftHip',swing*.3); turn('RightHip',-swing*.3)
        else
            turn('Waist',math.sin(now*2)*.018)
            turn('LeftShoulder',math.sin(now*2)*.015,0,-.025)
            turn('RightShoulder',-math.sin(now*2)*.015,0,.025)
        end
        if holdingTool then turn('RightShoulder',-1.05); turn('RightElbow',-.15) end
        pose.RootJoint=pose.Root
        return pose
    end
    local function getMorphTrack(animator,key,id)
        if failedAnimations[key] then return nil end
        local track=animationCache[key]
        if not track then
            local clip=new('Animation',{AnimationId=id})
            local ok,result=pcall(function() return animator:LoadAnimation(clip) end); clip:Destroy()
            if not ok then failedAnimations[key]=true; return nil end
            track=result; animationCache[key]=track; loadStarted[key]=os.clock()
        end
        if track.Length<=0 and os.clock()-(loadStarted[key] or 0)>5 then
            pcall(function() track:Stop(0); track:Destroy() end)
            animationCache[key]=nil; failedAnimations[key]=true; return nil
        end
        return track
    end
    local function syncAnimations()
        if not driver or not currentCharacter then return end
        local h=currentCharacter:FindFirstChildOfClass('Humanoid'); local r=charRoot(me)
        local controller=driver:FindFirstChildOfClass('AnimationController')
        local animator=controller and controller:FindFirstChildOfClass('Animator')
        if not h or not r or not animator then return end
        motion.kind,motion.rate,motion.jumpUntil=selectMorphMotion(h,r,os.clock(),motion.jumpUntil)
        local dance=catalogDanceSource and catalogDanceSource()
        motion.emote=dance~=nil and dance.IsPlaying
        local key,id
        if motion.emote and dance.Animation then id=dance.Animation.AnimationId; key='emote:'..id
        else motion.emote=false; key='motion:'..motion.kind; id='rbxassetid://'..motionIds[motion.kind] end
        local track=getMorphTrack(animator,key,id)
        motion.track=track
        if track then
            track.Priority=motion.emote and Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Movement
            if motion.emote then track.Looped=dance.Looped else track.Looped=motion.kind~='jump' end
            local speed=motion.emote and dance.Speed or motion.rate
            if not track.IsPlaying then track:Play(.12,1,speed) end
            -- A zero-weight source track must never mute the local avatar.
            track:AdjustWeight(1,.1); track:AdjustSpeed(speed)
            if motion.emote and math.abs(track.TimePosition-dance.TimePosition)>.2 then
                pcall(function() track.TimePosition=dance.TimePosition end)
            end
        end
        for other,value in pairs(animationCache) do if other~=key and value.IsPlaying then value:Stop(.12) end end
    end
    local function updateProceduralMorph(dt)
        if not driver or not currentCharacter then proceduralPose=nil; return end
        local now=os.clock()
        local changed=false
        for _,entry in ipairs(poseJoints) do
            local transform=entry.joint.Transform
            local previous=motion.observed[entry.joint]
            if (previous and previous~=transform) or (not previous and transform~=CFrame.new()) then changed=true end
            motion.observed[entry.joint]=transform
        end
        if changed then motion.lastChange=now end
        local track=motion.track
        local ready=track and track.IsPlaying and track.Length>0 and track.WeightCurrent>.01
        local articulated=motion.lastChange>0 and (now-motion.lastChange<.65 or motion.kind=='idle' or motion.kind=='sit')
        local fallback=not ready or not articulated
        local frequency=motion.kind=='run' and 2.2 or 1.6
        motion.phase=(motion.phase+math.min(dt,.1)*math.pi*2*frequency*motion.rate)%(math.pi*2)
        if fallback then
            local holding=currentCharacter:FindFirstChildOfClass('Tool')~=nil
            proceduralPose=proceduralMorphPose(motion.kind,motion.phase,now,holding)
        else proceduralPose=nil end
        local caption
        if motion.emote then
            caption=fallback and 'Эмоция не воспроизвелась на морфе; используются базовые движения.' or 'Анимации: эмоция.'
        else
            caption=(fallback and 'Анимации: базовое движение без загрузки • ' or 'Анимации: стандартные R15 • ')..motionNames[motion.kind]
        end
        if motion.lastCaption~=caption then motionStatus.Text=caption; motion.lastCaption=caption end
    end
    local function syncTools()
        for source,entry in pairs(catalogToolMirrors) do
            if not source:IsDescendantOf(currentCharacter) then entry.part:Destroy(); catalogToolMirrors[source]=nil end
        end
        local hand=currentCharacter:FindFirstChild('RightHand')
        local visibleHand=catalogRig:FindFirstChild('RightHand')
        if not hand or not visibleHand then return end
        for _,tool in ipairs(currentCharacter:GetChildren()) do if tool:IsA('Tool') then
            for _,source in ipairs(tool:GetDescendants()) do if source:IsA('BasePart') and not catalogToolMirrors[source] then
                local part=cleanPart(source)
                if part then
                    local state=hiddenProperties[source]; local alpha=state and state.transparency or source.Transparency
                    part.Name='CatalogTool_'..source.Name; part:SetAttribute('SakuraVisualRole','Tool'); part:SetAttribute('SakuraToolOriginalAlpha',alpha)
                    part.Transparency=alpha
                    for _,decal in ipairs(part:GetChildren()) do
                        if decal:IsA('Decal') then
                            local original=source:FindFirstChild(decal.Name)
                            local state=original and hiddenProperties[original]
                            if state then decal.Transparency=state.transparency end
                        end
                    end
                    part.Parent=catalogRig
                    catalogToolMirrors[source]={part=part,hand=hand,visibleHand=visibleHand}
                end
            end end
        end end
    end
    connect(RunService.PreSimulation,function()
        if not catalogRig or not driver or me.Character~=currentCharacter then return end
        local r=charRoot(me); local h=currentCharacter:FindFirstChildOfClass('Humanoid')
        local dr=driver:FindFirstChild('HumanoidRootPart')
        if r and h and dr then
            -- Move the entire hidden model, including any anchored loose parts.
            -- Never relocate only HumanoidRootPart while leaving limbs behind.
            driver:PivotTo(r.CFrame*CFrame.new(0,hipHeight-h.HipHeight,0))
        end
    end)
    connect(RunService.PostSimulation,function(dt)
        if catalogRig and driver and me.Character==currentCharacter then updateProceduralMorph(dt); sampleCatalogPose() end
    end)
    RunService:BindToRenderStep(binding,Enum.RenderPriority.Camera.Value+5,function(dt)
        if not catalogRig or not driver or me.Character~=currentCharacter then return end
        local ok,err=pcall(function()
            local r=charRoot(me); local h=currentCharacter:FindFirstChildOfClass('Humanoid')
            local dr=driver:FindFirstChild('HumanoidRootPart')
            if not r or not h or not dr then return end
            local frame=r.CFrame*CFrame.new(0,hipHeight-h.HipHeight,0)
            for _,part in ipairs(displayParts) do
                if part.Parent then
                    if not accessoryBindings.parts[part] then
                        -- Camera/current character position is the only source
                        -- of world translation; animation contributes local pose.
                        local relative=poseOffsets[part]
                        if relative then part.CFrame=frame*relative end
                    end
                    part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
                    part.LocalTransparencyModifier=0
                    part.Transparency=math.max(part:GetAttribute('SakuraCatalogOriginalAlpha') or 0,customOn and customTransparency or 0)
                end
            end
            renderAccessories(accessoryBindings)
            syncTimer+=dt
            if syncTimer>=.1 then syncTimer=0; syncAnimations(); syncTools() end
            for source,entry in pairs(catalogToolMirrors) do
                if source:IsDescendantOf(currentCharacter) then entry.part.CFrame=entry.visibleHand.CFrame*entry.hand.CFrame:ToObjectSpace(source.CFrame) end
            end
        end)
        if not ok then clearRig(); notify('Примерка остановлена: '..tostring(err)) end
    end)
    respawnHooks.catalog=function() generation+=1; itemGeneration+=1; morphVersion+=1; clearRig() end
    connect(me.CharacterAdded,function(character)
        if morphOn then
            local version=morphVersion
            task.spawn(function()
                local deadline=os.clock()+12
                while alive and morphOn and version==morphVersion and me.Character==character
                    and not bodyComplete(character) and os.clock()<deadline do RunService.Heartbeat:Wait() end
                if alive and morphOn and version==morphVersion and me.Character==character and bodyComplete(character) then loadMorph() end
            end)
            return
        end
        if not description then return end
        local saved=description
        task.spawn(function()
            local deadline=os.clock()+12
            while alive and me.Character==character and not bodyComplete(character) and os.clock()<deadline do RunService.Heartbeat:Wait() end
            if alive and description==saved and me.Character==character and bodyComplete(character) then rebuilder(saved:Clone(),'Каталог') end
        end)
    end)
    local previousCleanup=customCleanup
    customCleanup=function()
        generation+=1; itemGeneration+=1; searchGeneration+=1; morphVersion+=1
        morphOn=false
        if morphBackup then morphBackup:Destroy(); morphBackup=nil end
        RunService:UnbindFromRenderStep(binding); clearRig()
        if description then description:Destroy(); description=nil end
        if previousCleanup then previousCleanup() end
    end
end)()


checkpoint('MM2')
-- MM2 (Murder Mystery 2): round-start shockwave (visual only, zero blast
-- pressure/radius), a short highlight flash on the murderer and sheriff, and a
-- round timer. Round state and roles come from the game's own client events
-- (RoundStart, RoundEndFade, UpdatePlayerData); the optional GetPlayerData
-- query is the read-only call the MM2 client itself makes. Falls back to the
-- knife/gun tool in a character. Nothing here sends gameplay actions.
;(function()
    local RS=game:GetService('ReplicatedStorage')
    local white=Color3.new(1,1,1)
    local mm2={wave=false,flash=false,timer=false,gun=true,query=true,duration=180,radius=600,hold=1,fade=.6,gunHold=3,gunFade=1,gunScan=0,gunWatch=0,roundActive=false,roundEnd=0,generation=0,roles={},flashed={},hooked=false,remotes={},gameTimer=nil,timerSearch=0}
    note(mm2Page,'Только для Murder Mystery 2. Всё локально: волна не наносит урона, подсветка и таймер видны только тебе. Начало раунда и роли берутся из событий игры (RoundStart, RoundEndFade, UpdatePlayerData), при необходимости — из GetPlayerData и по ножу/пистолету в руках.')
    local status=note(mm2Page,'MM2: ожидание…')
    local statusRaw='MM2: ожидание…'
    local function setStatus(v) if statusRaw~=v then statusRaw=v; status.Text=v end end
    local function anyFeature() return mm2.wave or mm2.flash or mm2.timer or mm2.gun end
    -- Role polling talks to the game, so only the explicit role features enable
    -- it: with just the gun watcher on, MM2's own events are the only source.
    local function pollFeatures() return mm2.wave or mm2.flash or mm2.timer end

    -- Round timer HUD under the launcher.
    local hud=new('Frame',{Name='SakuraRoundTimer',AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,52),Size=UDim2.fromOffset(132,30),BackgroundColor3=Color3.fromRGB(22,18,29),BackgroundTransparency=.12,BorderSizePixel=0,Visible=false,ZIndex=5},gui); round(hud,9)
    new('UIStroke',{Color=pink,Thickness=1,Transparency=.35},hud)
    local hudText=text(hud,'⏱ 3:00',15,nil,UDim2.fromScale(1,1)); hudText.TextXAlignment=Enum.TextXAlignment.Center; hudText.Font=Enum.Font.GothamBold; hudText.ZIndex=6; hudText:SetAttribute('SakuraNoTranslate',true)

    local SEGMENTS=36
    local function playWave(origin)
        local c=colors.mm2Wave
        local parts={}
        local burst=new('Part',{Name='SakuraBurst',Shape=Enum.PartType.Ball,Size=Vector3.new(2,2,2),Material=Enum.Material.Neon,Color=c:Lerp(white,.3),Transparency=.35,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,CFrame=CFrame.new(origin)},root)
        local light=new('PointLight',{Brightness=8,Range=60,Color=c,Shadows=false},burst)
        for i=1,SEGMENTS do
            parts[i]=new('Part',{Name='SakuraWave',Size=Vector3.new(1,4,1.2),Material=Enum.Material.Neon,Color=c,Transparency=.35,Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,CFrame=CFrame.new(origin)},root)
        end
        -- Classic explosion sprite only: zero pressure, zero radius, no joint damage.
        pcall(function()
            local ex=Instance.new('Explosion'); ex.BlastPressure=0; ex.BlastRadius=0; ex.DestroyJointRadiusPercent=0; ex.Position=origin; ex.Parent=workspace
        end)
        local flash=new('Frame',{Name='SakuraWaveFlash',Size=UDim2.fromScale(1,1),BackgroundColor3=c:Lerp(white,.5),BackgroundTransparency=.5,BorderSizePixel=0,ZIndex=40},gui)
        local radius,duration=mm2.radius,1.9
        local started=os.clock()
        local conn
        local function finish()
            if conn then conn:Disconnect(); conn=nil end
            for _,part in ipairs(parts) do pcall(function() part:Destroy() end) end
            pcall(function() burst:Destroy() end); pcall(function() flash:Destroy() end)
        end
        conn=connect(RunService.RenderStepped,function()
            if not alive then finish(); return end
            local k=math.min(1,(os.clock()-started)/duration)
            local eased=1-(1-k)^3
            local r=2+eased*radius
            local height=4+10*math.sin(math.min(1,k*1.5)*math.pi)
            local segment=(2*math.pi*r/SEGMENTS)*1.06+.5
            for i,part in ipairs(parts) do
                local angle=(i/SEGMENTS)*2*math.pi
                part.Size=Vector3.new(segment,height,1.2)
                part.CFrame=CFrame.new(origin)*CFrame.Angles(0,angle,0)*CFrame.new(0,height/2,-r)
                part.Transparency=.35+.65*k
            end
            local bk=math.min(1,k*4)
            burst.Size=Vector3.new(2+bk*48,2+bk*48,2+bk*48); burst.Transparency=.35+.65*bk
            light.Brightness=8*(1-k); light.Range=60+eased*radius*.5
            flash.BackgroundTransparency=.5+.5*math.min(1,k*3)
            if k>=1 then finish() end
        end)
    end

    local roleNames={Murderer='Мардер',Sheriff='Шериф'}
    local function flashRole(p,role)
        local character=p.Character; if not character then return end
        local c=role=='Murderer' and colors.mm2Murderer or colors.mm2Sheriff
        local h=new('Highlight',{Name='SakuraRoleFlash',Adornee=character,FillColor=c,OutlineColor=c,FillTransparency=.25,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},root)
        local tag=new('BillboardGui',{Name='SakuraRoleTag',Adornee=character:FindFirstChild('Head') or character,AlwaysOnTop=true,Size=UDim2.fromOffset(200,28),StudsOffset=Vector3.new(0,3.1,0)},gui)
        local l=text(tag,translate(roleNames[role] or role)..'  •  '..p.DisplayName,14,nil,UDim2.fromScale(1,1))
        l:SetAttribute('SakuraNoTranslate',true); l.TextXAlignment=Enum.TextXAlignment.Center; l.Font=Enum.Font.GothamBold; l.TextColor3=c; l.TextStrokeTransparency=.4
        local hold,fade=mm2.hold,mm2.fade
        local started=os.clock()
        local conn
        conn=connect(RunService.RenderStepped,function()
            local k=math.clamp((os.clock()-started-hold)/fade,0,1)
            if not alive or not character.Parent then k=1 end
            h.FillTransparency=.25+.75*k; h.OutlineTransparency=k; l.TextTransparency=k; l.TextStrokeTransparency=.4+.6*k
            if k>=1 then conn:Disconnect(); pcall(function() h:Destroy() end); pcall(function() tag:Destroy() end) end
        end)
    end

    -- Role data: {[playerName]={Role='Murderer'|'Sheriff'|'Hero'|'Innocent',...}}
    local function applyRoles(data)
        if type(data)~='table' then return false end
        local murderer,sheriff,any=nil,nil,false
        for name,info in pairs(data) do
            local role=type(info)=='table' and info.Role or info
            if type(name)=='string' and type(role)=='string' then
                any=true
                local p=Players:FindFirstChild(name)
                if p then
                    mm2.roles[p]=role
                    if role=='Murderer' then murderer=p elseif role=='Sheriff' then sheriff=p end
                end
            end
        end
        if not any then return false end
        mm2.murderer=murderer; mm2.sheriff=sheriff
        return murderer~=nil
    end
    local function scanTools()
        for _,p in ipairs(Players:GetPlayers()) do
            local ch=p.Character
            if ch then
                if ch:FindFirstChild('Knife') then mm2.murderer=p end
                if ch:FindFirstChild('Gun') then mm2.sheriff=p end
            end
        end
    end
    -- Sheriff's dropped gun. When the sheriff dies MM2 leaves the pistol on the
    -- ground; only parts that are loose in the workspace (never inside a
    -- character) are considered. The new one is marked for mm2.gunHold seconds
    -- and then fades out over mm2.gunFade seconds. Purely local visuals.
    -- These are instance-name fragments used for matching, never UI text:
    -- they must not go into the translation dictionary.
    local GUN_KEYS={'gun','pistol','revolver','colt','пистолет','оружие'}
    local gunSeen=setmetatable({},{__mode='k'})
    local gunWatched=setmetatable({},{__mode='k'})
    local gunFx={}
    local function gunLike(o)
        local name=tostring(o.Name):lower()
        for _,key in ipairs(GUN_KEYS) do if name:find(key,1,true) then return true end end
        return false
    end
    local function insideCharacter(o)
        local step=o
        while step and step~=workspace do
            if step:IsA('Model') then
                for _,p in ipairs(Players:GetPlayers()) do if p.Character==step then return true end end
            end
            step=step.Parent
        end
        return false
    end
    -- A gun is "loose" while its whole ancestor chain still lives in the
    -- workspace and no ancestor is a player character. Picking it up (into a
    -- character or a backpack) or destroying it ends the highlight.
    local function stillLoose(o)
        if not o.Parent then return false end
        local top=o
        while top.Parent and top.Parent~=workspace do top=top.Parent end
        if top.Parent~=workspace then return false end
        return not insideCharacter(o)
    end
    local function gunPart(o)
        if o:IsA('BasePart') then return o end
        local ok,found=pcall(function() return o:FindFirstChild('Handle') or o:FindFirstChildWhichIsA('BasePart',true) end)
        return ok and found or nil
    end
    mm2ColorChanged=function(_,c)
        for _,entry in ipairs(gunFx) do
            entry.highlight.FillColor=c; entry.highlight.OutlineColor=c
            entry.light.Color=c; entry.label.TextColor3=c
        end
    end
    local function gunCaption(remaining)
        return translate('Пистолет шерифа • шериф погиб')..'\n'..string.format('%.1f',remaining)..' '..translate('сек')
    end
    local function highlightGun(part)
        if not part or not part.Parent then return false end
        local c=colors.mm2Gun
        local highlight=new('Highlight',{Name='SakuraGunFlash',Adornee=part,FillColor=c,OutlineColor=c,FillTransparency=.15,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},root)
        local light=new('PointLight',{Name='SakuraGunLight',Color=c,Brightness=2.5,Range=14,Shadows=false},part)
        local tag=new('BillboardGui',{Name='SakuraGunTag',Adornee=part,AlwaysOnTop=true,Size=UDim2.fromOffset(250,44),StudsOffset=Vector3.new(0,2.4,0)},gui)
        local label=text(tag,'',14,nil,UDim2.fromScale(1,1))
        label:SetAttribute('SakuraNoTranslate',true); label.TextXAlignment=Enum.TextXAlignment.Center
        label.Font=Enum.Font.GothamBold; label.TextColor3=c; label.TextStrokeTransparency=.45
        label.Text=gunCaption(mm2.gunHold)
        local entry={highlight=highlight,light=light,tag=tag,label=label,part=part}
        table.insert(gunFx,entry)
        local hold,fade=mm2.gunHold,mm2.gunFade
        local started=os.clock()
        local conn
        local function finish()
            if conn then conn:Disconnect(); conn=nil end
            for index,item in ipairs(gunFx) do if item==entry then table.remove(gunFx,index); break end end
            pcall(function() highlight:Destroy() end); pcall(function() light:Destroy() end); pcall(function() tag:Destroy() end)
        end
        conn=connect(RunService.RenderStepped,function()
            -- Picked up or destroyed: stop immediately instead of fading nothing.
            if not stillLoose(part) then finish(); return end
            local passed=os.clock()-started
            local k=math.clamp((passed-hold)/fade,0,1)
            highlight.FillTransparency=.15+.85*k; highlight.OutlineTransparency=k
            light.Brightness=2.5*(1-k)
            label.TextTransparency=k; label.TextStrokeTransparency=.45+.55*k
            label.Text=gunCaption(math.max(0,hold-passed))
            if not alive or k>=1 then finish() end
        end)
        return true
    end
    local function scanGuns()
        local count=0
        local function use(o)
            if not o or gunSeen[o] or not gunLike(o) or insideCharacter(o) then return end
            local part=gunPart(o)
            if not part then return end
            gunSeen[o]=true
            if highlightGun(part) then count+=1 end
        end
        local ok,list=pcall(function() return workspace:GetChildren() end)
        if not ok then return 0 end
        for _,o in ipairs(list) do
            if o:IsA('BasePart') then use(o)
            elseif o:IsA('Model') or o:IsA('Tool') then
                if gunLike(o) then use(o)
                else
                    local okChildren,children=pcall(function() return o:GetChildren() end)
                    if okChildren then for _,child in ipairs(children) do if child:IsA('BasePart') then use(child) end end end
                end
            end
        end
        return count
    end
    local function watchSheriff(p)
        local character=p and p.Character
        if not character or gunWatched[character] then return end
        local ok,humanoid=pcall(function() return character:FindFirstChildOfClass('Humanoid') end)
        if not ok or not humanoid then return end
        gunWatched[character]=true
        connect(humanoid.Died,function()
            if not alive or mm2.sheriff~=p then return end
            mm2.gunWatch=os.clock()+8
            setStatus('MM2: шериф погиб • ищу пистолет')
        end)
    end

    local function queryRoles()
        local remote=mm2.remotes.get
        if not (mm2.query and remote) then return false end
        local ok,data=pcall(function() return remote:InvokeServer() end)
        if ok then return applyRoles(data) end
        return false
    end

    local function endRound(reason)
        if not mm2.roundActive then return end
        mm2.roundActive=false; mm2.generation+=1; hud.Visible=false
        mm2.murderer,mm2.sheriff=nil,nil; mm2.roles={}
        setStatus('MM2: раунд завершён'..(reason and (' • '..reason) or ''))
    end
    local function nearestOther()
        local r=me.Character and me.Character:FindFirstChild('HumanoidRootPart')
        local best,dist=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            local pr=p~=me and p.Character and p.Character:FindFirstChild('HumanoidRootPart')
            if pr then
                local d=r and (pr.Position-r.Position).Magnitude or 0
                if d<dist then best,dist=p,d end
            end
        end
        return best
    end
    local function startRound(test)
        mm2.generation+=1; local g=mm2.generation
        -- Roles received just before RoundStart (UpdatePlayerData) are kept; they
        -- are cleared when a round ends so stale roles never flash.
        mm2.roundActive=true; mm2.roundEnd=os.clock()+mm2.duration; mm2.flashed={}; mm2.gameTimer=nil; mm2.timerSearch=0
        gunSeen=setmetatable({},{__mode='k'}); mm2.gunWatch=0
        if mm2.wave or test then
            task.delay(test and 0 or .35,function()
                if not alive or g~=mm2.generation then return end
                local r=me.Character and me.Character:FindFirstChild('HumanoidRootPart')
                if r then playWave(r.Position) end
            end)
        end
        hud.Visible=mm2.timer or test
        if test then
            flashRole(me,'Murderer')
            local other=nearestOther(); if other then flashRole(other,'Sheriff') end
            setStatus('MM2: тестовый запуск'); return
        end
        if mm2.flash then
            task.spawn(function()
                local deadline=os.clock()+10; local attempts=0
                while alive and g==mm2.generation and os.clock()<deadline do
                    if not (mm2.murderer and mm2.sheriff) then
                        attempts+=1
                        if attempts<=6 then queryRoles() end
                        scanTools()
                    end
                    for _,entry in ipairs({{role='Murderer',p=mm2.murderer},{role='Sheriff',p=mm2.sheriff}}) do
                        if entry.p and not mm2.flashed[entry.p] then mm2.flashed[entry.p]=true; flashRole(entry.p,entry.role) end
                    end
                    if mm2.murderer and mm2.sheriff then break end
                    task.wait(.6)
                end
            end)
        end
        setStatus('MM2: раунд идёт')
    end

    local function find(name,class)
        local ok,o=pcall(function() return RS:FindFirstChild(name,true) end)
        if ok and o and o:IsA(class) then return o end
        return nil
    end
    local function hook()
        if mm2.hooked then return end; mm2.hooked=true
        local r={start=find('RoundStart','RemoteEvent'),stop=find('RoundEndFade','RemoteEvent'),update=find('UpdatePlayerData','RemoteEvent'),get=find('GetPlayerData','RemoteFunction')}
        mm2.remotes=r
        if r.start then connect(r.start.OnClientEvent,function() if alive and anyFeature() then startRound() end end) end
        if r.stop then connect(r.stop.OnClientEvent,function() if alive then endRound() end end) end
        if r.update then
            connect(r.update.OnClientEvent,function(data)
                if not alive then return end
                local hasMurderer=applyRoles(data)
                if not r.start and hasMurderer and not mm2.roundActive and anyFeature() then startRound()
                elseif not r.stop and not hasMurderer and mm2.roundActive and type(data)=='table' and next(data)~=nil then endRound() end
            end)
        end
        if not r.start and not r.update and r.get then
            -- No events exposed: poll the read-only role query every 3 s while a feature is on.
            task.spawn(function()
                while alive do
                    if pollFeatures() and mm2.query then
                        local has=queryRoles()
                        if has and not mm2.roundActive then startRound() elseif not has and mm2.roundActive then endRound() end
                    end
                    task.wait(3)
                end
            end)
        end
        local found={}
        for k in pairs(r) do table.insert(found,k) end
        table.sort(found)
        setStatus(#found>0 and ('MM2: найдено • '..table.concat(found,', ')) or 'MM2: игра не похожа на Murder Mystery 2 (события не найдены)')
    end

    -- Snap the local countdown to the game's own m:ss timer label when one exists.
    local function findGameTimer()
        local pg=me:FindFirstChildOfClass('PlayerGui'); if not pg then return nil end
        for _,o in ipairs(pg:GetDescendants()) do
            if o:IsA('TextLabel') and o.Visible then
                local m,sec=tostring(o.Text):match('^%s*(%d+):(%d%d)%s*$')
                if m then
                    local n=o.Name:lower()
                    if (n:find('time') or n:find('clock')) and tonumber(m)*60+tonumber(sec)<=mm2.duration+5 then return o end
                end
            end
        end
        return nil
    end
    local lastShown
    connect(RunService.Heartbeat,function()
        if not mm2.roundActive or not hud.Visible then return end
        local label=mm2.gameTimer
        if not (label and label.Parent) then
            label=nil
            if os.clock()-mm2.timerSearch>2 then mm2.timerSearch=os.clock(); local ok,found=pcall(findGameTimer); if ok then label=found end; mm2.gameTimer=label end
        end
        if label then
            local m,sec=tostring(label.Text):match('^%s*(%d+):(%d%d)%s*$')
            if m then
                local remaining=tonumber(m)*60+tonumber(sec)
                if math.abs((mm2.roundEnd-os.clock())-remaining)>2 then mm2.roundEnd=os.clock()+remaining end
            end
        end
        local remaining=math.max(0,mm2.roundEnd-os.clock())
        local shown=string.format('⏱ %d:%02d',math.floor(remaining/60),math.floor(remaining%60))
        if shown~=lastShown then lastShown=shown; hudText.Text=shown; hudText.TextColor3=remaining<=30 and Color3.fromRGB(255,110,110) or white end
        if remaining<=0 then endRound('время вышло') end
    end)

    -- Gun watcher: 0.3 s paced, only during a round or for 8 s after the
    -- sheriff's death, so the loop costs nothing while nothing can happen.
    connect(RunService.Heartbeat,function()
        if not mm2.gun then return end
        if not (mm2.roundActive or os.clock()<mm2.gunWatch) then return end
        if os.clock()-mm2.gunScan<.3 then return end
        mm2.gunScan=os.clock()
        if mm2.sheriff then watchSheriff(mm2.sheriff) end
        local ok,count=pcall(scanGuns)
        if ok and count>0 then setStatus('MM2: пистолет шерифа подсвечен') end
    end)

    toggle(mm2Page,'MM2 • взрыв-волна на старте раунда (без урона)',false,function(on) mm2.wave=on; if on then hook() end end)
    toggle(mm2Page,'MM2 • подсветка мардера и шерифа на старте',false,function(on) mm2.flash=on; if on then hook() end end)
    toggle(mm2Page,'MM2 • таймер раунда',false,function(on) mm2.timer=on; if on then hook() end; if mm2.roundActive then hud.Visible=on end end)
    toggle(mm2Page,'MM2 • запрашивать роли через GetPlayerData',true,function(on) mm2.query=on end)
    numberSlider(mm2Page,'Радиус волны',50,1500,600,'',function(v) mm2.radius=v end)
    numberSlider(mm2Page,'Длительность раунда',60,300,180,'',function(v) mm2.duration=v end)
    numberSlider(mm2Page,'Подсветка держится',1,5,1,'',function(v) mm2.hold=v end)
    toggle(mm2Page,'MM2 • подсветить пистолет, когда шериф погиб',true,function(on) mm2.gun=on; if on then hook() end end)
    numberSlider(mm2Page,'Пистолет держится',1,10,3,'',function(v) mm2.gunHold=v end)
    numberSlider(mm2Page,'Пистолет гаснет',1,5,1,'',function(v) mm2.gunFade=v end)
    connect(button(mm2Page,'Тест сейчас: волна + подсветка + таймер').Activated,function() hook(); startRound(true) end)
    connect(button(mm2Page,'Сбросить таймер').Activated,function() endRound('сброс') end)
    note(mm2Page,'Таймер: 3:00 по умолчанию (раунд MM2), при наличии подхватывает таймер самой игры. Подсветка: держится указанное время и плавно гаснет за 0.6 с.')
    note(mm2Page,'Пистолет шерифа: когда шериф погибает, пистолет падает на землю — он подсвечивается 3 секунды, рядом идёт отсчёт, потом плавно гаснет. Работает только во время раунда MM2 и только если пистолет виден клиенту.')
    colorPicker('mm2Wave','MM2 • волна')
    colorPicker('mm2Murderer','MM2 • мардер')
    colorPicker('mm2Sheriff','MM2 • шериф')
    colorPicker('mm2Gun','MM2 • пистолет шерифа')
    if mm2.gun then hook() end
end)()

local weatherTimer=0
connect(RunService.RenderStepped,function(dt)
    local camera=workspace.CurrentCamera; if not camera then return end
    scale.Scale=math.min(1,(camera.ViewportSize.X-20)/650,(camera.ViewportSize.Y-76)/490)
    local t=os.clock()
    for p,entries in pairs(effects) do
        local cape=entries.cape; local r=charRoot(p)
        local trail=entries.trail
        if trail and trail.spawn and r then trailFX.update(trail,r,dt,t) end
        if cape and r then
            local torso=p.Character:FindFirstChild('UpperTorso') or p.Character:FindFirstChild('Torso') or r
            local speed=math.clamp(r.AssemblyLinearVelocity.Magnitude/30,0,1.5)
            local pivot=torso.CFrame*CFrame.new(0,torso.Size.Y*.43,torso.Size.Z/2+.16)
            for i,part in ipairs(cape.segments) do
                local bend=.025+speed*.06+math.sin(t*3-i*.35)*.035
                pivot=pivot*CFrame.Angles(-bend,0,math.sin(t*2-i*.2)*.008)*CFrame.new(0,-.095,0)
                part.CFrame=pivot; pivot=pivot*CFrame.new(0,-.095,0)
            end
            capeFX.follow(cape,pivot)
        end
    end
    if hat then
        local visible=catalogRig or danceRig or me.Character
    local head=visible and visible:FindFirstChild('Head')
        if head and not hatDrawingMode then hat:PivotTo(head.CFrame*CFrame.new(0,head.Size.Y*.5+.35,0)*hatOffset) else hat:PivotTo(CFrame.new(0,-10000,0)) end
    end
    if hatDrawingMode then
        local success=pcall(updateHatDrawing,camera)
        if not success then
            hatDrawingMode=false; clearHatDrawing()
            if setDrawingToggle then setDrawingToggle(false) end
            notify('Ошибка Drawing API: возвращаю 3D-шляпу.')
            if state.hat and not hat then loadHat() end
        end
    end
    weatherTimer+=dt
    local eye=camera.CFrame.Position
    weather.near.CFrame=CFrame.new(eye+Vector3.new(0,14,0))
    weather.far.CFrame=CFrame.new(eye+Vector3.new(0,30,0))
    if weatherTimer>.18 then
        weatherTimer=0
        weather.update(camera,eye)
    end
    updateTarget(camera)
end)
checkpoint('Config')
;(function()
    -- Configs. Every config has a permanent unique id (sv-XXXXXX) that is never
    -- edited, plus any name you like. A config captures the whole menu and puts
    -- it back in one click. Everything is stored locally in
    -- sakuravisuals_configs.json — no server takes part.
    local FILE='sakuravisuals_configs.json'
    local canFile=type(writefile)=='function' and type(readfile)=='function'
    local canClipboard=type(setclipboard)=='function' and type(getclipboard)=='function'
    local store=cfgCore.blankStore()
    local selected=nil
    local load

    local function persist()
        local text=cfgCore.writeStore(store)
        if not text then return false end
        if canFile then
            local ok=pcall(writefile,FILE,text)
            if not ok then notify('Не удалось записать файл конфигов — нет доступа к файлам.'); return false end
        else
            env.SakuraVisualsConfigs=text
        end
        return true
    end
    local function restore()
        local text
        if canFile then
            local ok,value=pcall(readfile,FILE)
            if ok and type(value)=='string' and #value>0 then text=value end
        elseif type(env.SakuraVisualsConfigs)=='string' then
            text=env.SakuraVisualsConfigs
        end
        if not text then return false end
        local parsed=cfgCore.readStore(text)
        if parsed then store=parsed; return true end
        notify('Файл конфигов повреждён — начинаю с пустого списка.')
        return false
    end

    note(configPage,'Config • конфиги меню. У каждого конфига постоянный ID вида sv-123456: по нему конфиг находится, изменить ID нельзя. Название можно любое — придумай своё.')
    note(configPage,'Что сохраняется: все тумблеры и слайдеры, цвета (включая MM2), вид трейла, картинка на плащ и ник морфа. Конфигов может быть сколько угодно: например «MM2», «красиво», «лёгкий для телефона» — и переключение одним нажатием.')
    note(configPage,'Зачем это нужно: вернуть свои настройки после перезахода (галочка автозагрузки), безопасно экспериментировать — сохранил и вернул, и передать набор другому игроку. Конфиги лежат у тебя на устройстве в файле sakuravisuals_configs.json, поэтому ID сам по себе чужой конфиг не откроет: чтобы поделиться, скопируй экспорт-строку.')

    local idRow=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)},configPage)
    local idInput=new('TextBox',{PlaceholderText='ID конфига, например sv-123456',ClearTextOnFocus=false,Font=Enum.Font.Code,TextSize=13,
        TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(43,35,54),BorderSizePixel=0,Size=UDim2.new(.56,-6,1,0)},idRow); round(idInput,8)
    local addButton=button(idRow,'Добавить по ID',UDim2.new(.44,0,1,0),UDim2.fromScale(.56,0))
    local nameRow=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)},configPage)
    local nameInput=new('TextBox',{PlaceholderText='Название конфига (любое)',ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=13,
        TextColor3=Color3.new(1,1,1),BackgroundColor3=Color3.fromRGB(43,35,54),BorderSizePixel=0,Size=UDim2.new(.56,-6,1,0)},nameRow); round(nameInput,8)
    local renameButton=button(nameRow,'Переименовать',UDim2.new(.44,0,1,0),UDim2.fromScale(.56,0))
    local function pairRow()
        local row=new('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,0,0,38)},configPage)
        local left=button(row,'',UDim2.new(.5,-3,1,0))
        local right=button(row,'',UDim2.new(.5,-3,1,0),UDim2.fromScale(.5,0)+UDim2.new(0,3,0,0))
        return left,right
    end
    local newIdButton,saveButton=pairRow()
    newIdButton.Text='Новый ID'
    saveButton.Text='Сохранить настройки'
    local loadButton,deleteButton=pairRow()
    loadButton.Text='Загрузить выбранный'
    deleteButton.Text='Удалить конфиг'
    local copyIdButton,exportButton=pairRow()
    copyIdButton.Text='Копировать ID'
    exportButton.Text='Экспорт в буфер'
    local importButton,offAllButton=pairRow()
    importButton.Text='Импорт из буфера'
    offAllButton.Text='Выключить всё'
    local setAutoload
    setAutoload=toggle(configPage,'Config • загружать выбранный конфиг при запуске',store.autoload~=nil,function(on)
        if on and not selected then notify('Сначала выбери конфиг по ID.'); setAutoload(false); return end
        store.autoload=on and selected and selected.id or nil
        persist()
    end)
    local status=note(configPage,'Конфигов нет.')
    local cards=new('Frame',{Name='ConfigCards',BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},configPage)
    new('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},cards)
    local cardButtons={}

    local function stamp(config)
        local time=tonumber(config.updated) or 0
        if time<=0 then return '' end
        local ok,text=pcall(function() return os.date('%d.%m %H:%M',time) end)
        return ok and text or ''
    end
    local function drawCards()
        for _,card in ipairs(cardButtons) do pcall(function() card:Destroy() end) end
        cardButtons={}
        local list=cfgCore.list(store)
        status.Text=selected and ('Выбран: '..selected.name..'  ['..selected.id..'] • конфигов: '..#list) or ('Конфигов: '..#list..' • выбери конфиг по ID или создай новый')
        for index,config in ipairs(list) do
            -- Config names are user text: never translated, never executable.
            local card=button(cards,(selected and selected.id==config.id and '●  ' or '○  ')..config.name..'   ['..config.id..']   •   '..cfgCore.count(config.data)..' ⚙   •   '..stamp(config),UDim2.new(1,0,0,36))
            card.LayoutOrder=index
            card:SetAttribute('SakuraNoTranslate',true)
            table.insert(cardButtons,card)
            connect(card.Activated,function()
                selected=config
                idInput.Text=config.id
                nameInput.Text=config.name
                load(config)
                drawCards()
            end)
        end
    end
    load=function(config,quiet)
        if not config then notify('Сначала выбери конфиг по ID.'); return 0,{} end
        local applied,missed=cfgCore.apply(config.data,cfgRegistry.order,cfgExtras.order,function(key,color)
            recolor(key,color)
            if colorPickerRefresh[key] then pcall(colorPickerRefresh[key]) end
        end,function() task.wait(.04) end)
        if not quiet then notify('Применено: '..applied..' • пропущено: '..#missed) end
        return applied,missed
    end
    local function select(config)
        selected=config
        idInput.Text=config.id
        nameInput.Text=config.name
        drawCards()
    end
    local function nameFrom(placeholder)
        local value=nameInput.Text:match('^%s*(.-)%s*$')
        if value=='' then return placeholder end
        return value:sub(1,40)
    end

    connect(addButton.Activated,function()
        local id=cfgCore.parseId(idInput.Text)
        if not id then notify('ID должен быть вида sv-123456: латиница sv, дефис и цифры.'); return end
        local existing=store.configs[id]
        if existing then
            select(existing)
            notify('Конфиг найден: '..existing.name..' ['..existing.id..']')
            load(existing)
            return
        end
        local config=cfgCore.upsert(store,id,nameInput.Text~='' and nameFrom(id) or id)
        persist()
        select(config)
        notify('Конфиг создан: '..config.name..' ['..config.id..'] • сохрани в него настройки')
    end)
    connect(newIdButton.Activated,function()
        local id=cfgCore.newId(function(candidate) return store.configs[candidate]~=nil end)
        local config=cfgCore.upsert(store,id,nameFrom(id))
        persist()
        idInput.Text=id
        select(config)
        if canClipboard then pcall(setclipboard,id) end
        notify('Новый ID: '..id..' • имя можно поменять, ID останется таким навсегда')
    end)
    connect(renameButton.Activated,function()
        if not selected then notify('Сначала выбери конфиг по ID.'); return end
        local value=nameInput.Text:match('^%s*(.-)%s*$')
        if value=='' then notify('Название не может быть пустым — ID остаётся прежним.'); return end
        selected.name=value:sub(1,40)
        selected.updated=os.time()
        persist()
        drawCards()
        notify('Название сохранено. ID конфига не меняется: '..selected.id)
    end)
    connect(saveButton.Activated,function()
        if not selected then notify('Сначала выбери конфиг по ID.'); return end
        selected.data=cfgCore.capture(cfgRegistry.order,cfgExtras.order,colors)
        selected.updated=os.time()
        persist()
        drawCards()
        notify('Сохранено настроек: '..cfgCore.count(selected.data)..' • конфиг '..selected.name..' ['..selected.id..']')
    end)
    connect(loadButton.Activated,function()
        if not selected then notify('Сначала выбери конфиг по ID.'); return end
        load(selected)
        drawCards()
    end)
    local pendingDelete=nil
    connect(deleteButton.Activated,function()
        if not selected then notify('Сначала выбери конфиг по ID.'); return end
        if pendingDelete~=selected.id then
            pendingDelete=selected.id
            notify('Нажми ещё раз, чтобы удалить конфиг '..selected.name..' ['..selected.id..']')
            return
        end
        pendingDelete=nil
        local name,id=selected.name,selected.id
        cfgCore.remove(store,selected.id)
        selected=nil
        persist()
        drawCards()
        notify('Конфиг удалён: '..name..' ['..id..']')
    end)
    connect(copyIdButton.Activated,function()
        if not selected then notify('Сначала выбери конфиг по ID.'); return end
        if not canClipboard then notify('Буфер обмена недоступен: ID конфига — '..selected.id); return end
        pcall(setclipboard,selected.id)
        notify('ID скопирован: '..selected.id)
    end)
    connect(exportButton.Activated,function()
        if not selected then notify('Сначала выбери конфиг по ID.'); return end
        local text=cfgCore.encode(selected)
        if not text then notify('Не удалось собрать конфиг для экспорта.'); return end
        if not canClipboard then notify('Буфер обмена недоступен — экспорт некуда положить.'); return end
        pcall(setclipboard,text)
        notify('Экспорт конфига скопирован: '..selected.name..' ['..selected.id..'] • передай строку тому, кому нужен конфиг')
    end)
    connect(importButton.Activated,function()
        if not canClipboard then notify('Буфер обмена недоступен в этом исполнителе.'); return end
        local ok,text=pcall(getclipboard)
        if not ok or type(text)~='string' or #text==0 then notify('В буфере нет данных конфига.'); return end
        local decoded=cfgCore.decode(text)
        local imported=nil
        if type(decoded)=='table' and decoded.configs then
            local candidate=cfgCore.readStore(decoded)
            local list=candidate and cfgCore.list(candidate) or {}
            imported=list[1]
        elseif type(decoded)=='table' and decoded.id then
            local candidate=cfgCore.readStore({configs={[tostring(decoded.id)]=decoded}})
            imported=candidate and candidate.configs[cfgCore.parseId(decoded.id)]
        end
        if not imported then notify('Импорт: в буфере не конфиг sakuravisuals.'); return end
        store.configs[imported.id]=imported
        persist()
        select(imported)
        notify('Импорт: конфиг '..imported.name..' ['..imported.id..'] добавлен')
    end)
    connect(offAllButton.Activated,function()
        local count=0
        for _,entry in ipairs(cfgRegistry.order) do
            if entry.kind=='toggle' and entry.key:sub(1,6)~='Config' then
                local ok,value=pcall(entry.get)
                if ok and value then pcall(entry.set,false); count+=1; task.wait(.03) end
            end
        end
        drawCards()
        notify('Выключено функций: '..count)
    end)

    restore()
    setAutoload(store.autoload~=nil)
    if store.autoload and store.configs[store.autoload] then
        select(store.configs[store.autoload])
        local config=store.configs[store.autoload]
        task.delay(4,function()
            if not alive then return end
            local applied=load(config,true)
            notify('Конфиг при запуске: '..config.name..' • настроек: '..applied)
        end)
    else
        drawCards()
    end
end)()
checkpoint('готово • вкладок 14')
pcall(function() task.delay(6,function() loadLabel.Visible=false end) end)
notify('sakuravisuals.cc готов • кнопка сверху / RightShift')

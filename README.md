# Смысл

Смысл в том, что надоело при деплое ждать когда rake загрузит все
рельсовое окружение, которое на момент деплоя нафиг не нужно. Рецепт
оказался простым - выносим влада в отдельный `Rakefile`.

# Установка

    git submodule add git://github.com/BrandyMint/vlad_deploy.git ./script/vlad
    git submodule init
    git submodule update
    cd ./script/vlad; bundle
    cd ../..
    cp ./script/vlad/deploy_config.rb ./config/deploy.rb
    vi ./config/deploy.rb
    
# Настройка сервера

    rake -N -f ./script/vlad/Rakefile vlad:setup DEPLOY_TO=production
    
# Подключаем unicorn в проект 
# Настраиваем веб-сервер (nginx/apache)
=======
    cp ./script/vlad/config/* ./config/
    vi ./config/deploy.rb ./config/unicorn.rb

# Быстрый деплой

    ./script/vlad/deploy

# Статейка об этом модуле

* http://dapi.ru/vlad-submodule

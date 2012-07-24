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
    cp script/vlad/config/deploy.rb config/
    vi ./config/deploy.rb
    
# Подключаем unicorn в проект 

   cp ./script/vlad/config/unicorn.rb ./config/
   vi ./config/unicorn.rb  # Change application
    
# Настройка сервера

    rake -N -f ./script/vlad/Rakefile vlad:setup DEPLOY_TO=production 

# Настраиваем веб-сервер (nginx/apache) на сервере

# git push

# Быстрый деплой

    ./script/vlad/deploy

# Статейка об этом модуле

* http://dapi.ru/vlad-submodule

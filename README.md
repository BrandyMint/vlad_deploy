# Смысл

Смысл в том, что надоело при деплое ждать когда rake загрузит все
рельсовое окружение, которое на момент деплоя нафиг не нужно. Рецепт
оказался простым - выносим влада в отдельный `Rakefile`.

# Установка

    git submodule git://github.com/dapi/vlad_deploy.git ./script/vlad
    cp ./script/vlad/deploy_config.rb ./config/deploy.rb
    vi ./config/deploy.rb

# Быстрый деплой

    ./script/vlad/deploy

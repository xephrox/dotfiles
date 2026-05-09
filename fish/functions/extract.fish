function extract --description 'Extract any archive'
    for archive in $argv
        if test -f $archive
            switch $archive
                case '*.tar.bz2'
                    tar xvjf $archive
                case '*.tar.gz'
                    tar xvzf $archive
                case '*.bz2'
                    bunzip2 $archive
                case '*.rar'
                    rar x $archive
                case '*.gz'
                    gunzip $archive
                case '*.tar'
                    tar xvf $archive
                case '*.tbz2'
                    tar xvjf $archive
                case '*.tgz'
                    tar xvzf $archive
                case '*.zip'
                    unzip $archive
                case '*.Z'
                    uncompress $archive
                case '*.7z'
                    7z x $archive
                case '*'
                    echo "don't know how to extract '$archive'..."
            end
        else
            echo "'$archive' is not a valid file!"
        end
    end
end

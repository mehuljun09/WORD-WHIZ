#!/bin/bash

choose_word() {
    local word_list=("apple" "banana" "orange" "grape" "pear" "elephant" "target" "laptop" "rainbow" "ocean" "butter" "sunrise" "bike" "lender" "pencil" "stamp" "jelly" "adapter" "glasses" "ultra" "igloo")
    local word_index=$((RANDOM % ${#word_list[@]}))
    echo "${word_list[$word_index]}"
}

check_guess() {
    local word=$1
    local guess=$2

    if [ ${#guess} -ne ${#word} ]; then
        return 1
    fi

    for ((i=0; i<${#word}; i++)); do
        if [ "${word:$i:1}" != "${guess:$i:1}" ]; then
            return 1
        fi
    done

    return 0
}

main() {
    local play_again="yes"

    while [ "$play_again" = "yes" ]; do
        local word=$(choose_word)
        local guesses_left=6
        local guessed_words=()

        echo "Welcome to Word Whiz!"
        echo "Try to guess the word within 6 attempts."

        while [ $guesses_left -gt 0 ]; do
            echo
            echo "Guesses left: $guesses_left"
            echo "Guessed words: ${guessed_words[*]}"
            guessed_word=""

            for ((i=0; i<${#word}; i++)); do
                letter="${word:$i:1}"
                if [[ "${guessed_words[*]}" =~ $letter ]]; then
                    guessed_word+="$letter"
                else
                    guessed_word+="*"
                fi
            done

            echo "Word: $guessed_word"

            read -p "Enter your guess: " guess

            if [[ "${guessed_words[*]}" =~ $guess ]]; then
                echo "You've already guessed that word!"
                continue
            fi

            guessed_words+=("$guess")

            if check_guess "$word" "$guess"; then
                echo "Congratulations! You've guessed the word: $word"
                break
            else
                ((guesses_left--))
            fi
        done

        if [ $guesses_left -eq 0 ]; then
            echo "Sorry, you've run out of guesses. The word was: $word"
        fi

        read -p "Do you want to play again? (yes/no): " play_again
    done

    echo "Thanks for playing!"
}

main


#!/bin/bash

HINT_COST=5
TOTAL_SCORE_FILE="wordle_total_scores.txt"

# Function to choose a random word from the provided word list based on the chosen category
choose_word() {
    local category=$1
    local word_list=()

    case $category in
        "fruits")
            word_list=("apple" "banana" "orange" "grape" "pear")
            ;;
        "animals")
            word_list=("elephant" "tiger" "lion" "zebra" "giraffe")
            ;;
        "objects")
            word_list=("laptop" "bicycle" "television" "camera" "clock")
            ;;
        *)
            echo "Invalid category."
            exit 1
            ;;
    esac

    local index=$((RANDOM % ${#word_list[@]}))
    echo "${word_list[$index]}"
}

# Function to give a hint and deduct points from total score
give_hint() {
    local word=$1
    local remaining_letters=()

    for ((i=0; i<${#word}; i++)); do
        if [[ "${word:$i:1}" != "*" ]]; then
            remaining_letters+=("$i")
        fi
    done

    local hint_index=${remaining_letters[$((RANDOM % ${#remaining_letters[@]}))]}
    local hint="${word:$hint_index:1}"
    if [ "$total_score" -ge "$HINT_COST" ]; then
        local deducted_score=$((total_score - HINT_COST))  # Deduct points from total score for each hint
        total_score="$deducted_score"
        echo "$deducted_score" >> "$TOTAL_SCORE_FILE" # Write the deducted value into the file
        echo "$hint,$deducted_score" # Return hint and updated total score
    else
        echo "You don't have enough points for a hint!,0" # Return message indicating insufficient points and total score remains unchanged
    fi
}

# Function to check if the guessed word matches the target word
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

# Function to display total scores
display_total_scores() {
    if [ -f "$TOTAL_SCORE_FILE" ]; then
        zenity --text-info --title="Wordle Total Scores" --width=400 --height=300 --filename="$TOTAL_SCORE_FILE"
    else
        zenity --info --text="No total scores yet!"
    fi
}

# Main function
main() {
    local play_again="yes"
    local total_score=0

    while [ "$play_again" = "yes" ]; do
        local category=$(zenity --list --title="Wordle" --text="Choose a category:" --column="Categories" fruits animals objects)
        local word=$(choose_word "$category")
        local guesses_left=6
        local guessed_words=()
        local score=0

        zenity --info --text="Welcome to Wordle! Try to guess the word within 6 attempts."

        while [ $guesses_left -gt 0 ]; do
            guessed_word=""
            for ((i=0; i<${#word}; i++)); do
                letter="${word:$i:1}"
                if [[ "${guessed_words[*]}" =~ $letter ]]; then
                    guessed_word+="$letter"
                else
                    guessed_word+="*"
                fi
            done

            guess=$(zenity --entry --text="Guesses left: $guesses_left\nGuessed words: ${guessed_words[*]}\nWord: $guessed_word\nEnter your guess (or 'hint' for a hint):")

            if [[ -z "$guess" ]]; then
                continue
            fi

            if [ "$guess" = "hint" ]; then
                hint_info=$(give_hint "$word")
                hint=$(echo "$hint_info" | cut -d',' -f1)
                total_score=$(echo "$hint_info" | cut -d',' -f2)
                if [ "$hint" != "You don't have enough points for a hint!" ]; then
                    zenity --info --text="Hint: $hint\nTotal Score: $total_score"
                else
                    zenity --info --text="$hint"
                fi
                continue
            fi

            if [[ "${guessed_words[*]}" =~ $guess ]]; then
                zenity --info --text="You've already guessed that word!"
                continue
            fi
            guessed_words+=("$guess")

            if check_guess "$word" "$guess"; then
                score=$((score + guesses_left))
                zenity --info --text="Congratulations! You've guessed the word: $word\nScore: $score"
                break
            else
                ((guesses_left--))
                if [ $guesses_left -eq 0 ]; then
                    zenity --info --text="Sorry, you've run out of guesses. The word was: $word"
                fi
            fi
        done

        total_score=$((total_score + score))

        play_again=$(zenity --entry --text="Do you want to play again? (yes/no)")

        if [ "$play_again" = "no" ]; then
            zenity --info --text="Total Score: $total_score\nThanks for playing!"
            echo "$total_score" >> "$TOTAL_SCORE_FILE"
            display_total_scores
        fi
    done
}

main



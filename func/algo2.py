import sys
import pymysql


# Jaro-Winkler 유사도 계산 함수
def jaro_winkler(str1: str, str2: str) -> float:
    def get_matched_characters(_str1: str, _str2: str) -> str:
        matched = []
        limit = min(len(_str1), len(_str2)) // 2
        _str2_list = list(_str2)

        for i, l in enumerate(_str1):
            left = max(0, i - limit)
            right = min(i + limit + 1, len(_str2_list))
            if l in _str2_list[left:right]:
                matched.append(l)
                _str2_list[_str2_list.index(l)] = None

        return "".join(matched)

    matching_1 = get_matched_characters(str1, str2)
    matching_2 = get_matched_characters(str2, str1)
    match_count = len(matching_1)

    transpositions = sum(c1 != c2 for c1, c2 in zip(matching_1, matching_2)) // 2

    if not match_count:
        jaro = 0.0
    else:
        jaro = (1 / 3) * (
            match_count / len(str1) +
            match_count / len(str2) +
            (match_count - transpositions) / match_count
        )

    prefix_len = 0
    for c1, c2 in zip(str1[:4], str2[:4]):
        if c1 == c2:
            prefix_len += 1
        else:
            break

    return jaro + 0.1 * prefix_len * (1 - jaro)


# Jaccard 유사도 계산 함수
def calculate_jaccard_similarity(doc1: str, doc2: str) -> float:
    doc1_tokenized = set(doc1)
    doc2_tokenized = set(doc2)
    
    doc_union = doc1_tokenized.union(doc2_tokenized)
    doc_intersection = doc1_tokenized.intersection(doc2_tokenized)
    
    if len(doc_union) == 0:
        return 0.0
    
    return len(doc_intersection) / len(doc_union)

def find_similar_names(input_word: str, name_list: list) -> list:
    first_round_similarities = []

    for name in name_list:
        similarity = calculate_jaccard_similarity(name, input_word)
        if similarity > 0.5:
            first_round_similarities.append((name, similarity))

    first_round_similarities.sort(key=lambda x: x[1], reverse=True)
    return first_round_similarities

def compare_jaro_winkler(similarities_list: list, input_word: str):
    similarities = []
    
    for name, _ in similarities_list: 
        similarity = jaro_winkler(name, input_word)
        similarities.append((name, round(similarity, 2)))

    second_round_similarities = []
    for name, similarity in similarities:
        if similarity > 0.7 and abs(len(input_word) - len(name)) < 3:
            second_round_similarities.append((name, similarity))

    first_round_similarities.sort(key=lambda x: x[1], reverse=True)
    
    return second_round_similarities

def select_by_first_word(name: str, name_list: list) -> list:
    first_word = name[0]
    filtered_names = [n for n in name_list if n.startswith(first_word)]
    
    similarities_list = find_similar_names(name, filtered_names)
    second_round_similarities = compare_jaro_winkler(similarities_list, name)
    
    return second_round_similarities

# CSV 파일 경로 (이 부분은 실제 파일 경로로 수정)
#경로 수정 필요!!

def load_package_names() -> list:
    conn = pymysql.connect(
    host='localhost',
    user='ABO',
    password='!@ABOkSj0812@!',
    database='ABO',
    charset='utf8'
    )
    cursor = conn.cursor()
    
    cursor.execute("SELECT name FROM PackageName")
    rows = cursor.fetchall()
    
    conn.close()
    return [row[0] for row in rows]

def main(input_words):
    # 데이터베이스에서 패키지명 로드
    name_list = load_package_names()
    
    # 유사도 측정
    results = []
    for input_word in input_words:
        second_round_similarities = select_by_first_word(input_word, name_list)
        results.append((input_word, second_round_similarities))
    
    return results



